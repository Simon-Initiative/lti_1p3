defmodule Lti_1p3.KeyProviders.MemoryKeyProvider do
  @moduledoc """
  In-memory implementation of the KeyProvider behavior.

  This provider caches public keys in memory and supports automatic refresh
  based on cache-control headers from the key set URL responses.

  Features:
  - In-memory caching with configurable TTL
  - Automatic refresh based on HTTP cache headers
  - Background refresh of stale keys
  - Thread-safe concurrent access
  - Metrics and cache information
  """

  use GenServer
  require Logger

  import Lti_1p3.Config
  import Lti_1p3.Utils, only: [convert_map_to_base64url: 1]

  @behaviour Lti_1p3.KeyProvider

  # Default cache TTL in seconds (1 hour)
  @default_cache_ttl 3600
  # Default refresh interval in seconds (30 minutes)
  @default_refresh_interval 1800

  defmodule CacheEntry do
    @moduledoc false
    defstruct [:keys, :expires_at, :cache_control, :last_modified, :etag]

    @type t() :: %__MODULE__{
            keys: %{String.t() => JOSE.JWK.t()},
            expires_at: DateTime.t(),
            cache_control: String.t() | nil,
            last_modified: String.t() | nil,
            etag: String.t() | nil
          }
  end

  defmodule State do
    @moduledoc false
    defstruct cache: %{}, cache_hits: 0, cache_misses: 0, refresh_errors: 0

    @type t() :: %__MODULE__{
            cache: %{String.t() => CacheEntry.t()},
            cache_hits: non_neg_integer(),
            cache_misses: non_neg_integer(),
            refresh_errors: non_neg_integer()
          }
  end

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Lti_1p3.KeyProvider
  def get_public_key(key_set_url, kid) do
    GenServer.call(__MODULE__, {:get_public_key, key_set_url, kid})
  end

  @impl Lti_1p3.KeyProvider
  def preload_keys(key_set_url) do
    GenServer.call(__MODULE__, {:preload_keys, key_set_url})
  end

  @impl Lti_1p3.KeyProvider
  def refresh_all_keys() do
    GenServer.call(__MODULE__, :refresh_all_keys)
  end

  @impl Lti_1p3.KeyProvider
  def clear_cache() do
    GenServer.call(__MODULE__, :clear_cache)
  end

  @impl Lti_1p3.KeyProvider
  def cache_info() do
    GenServer.call(__MODULE__, :cache_info)
  end

  def refresh_stale_keys() do
    GenServer.cast(__MODULE__, :refresh_stale_keys)
  end

  ## Server Implementation

  @impl GenServer
  def init(opts) do
    state = %State{}

    # Schedule periodic refresh if enabled
    refresh_interval = Keyword.get(opts, :refresh_interval, @default_refresh_interval)

    if refresh_interval > 0 do
      schedule_refresh(refresh_interval)
    end

    {:ok, state}
  end

  @impl GenServer
  def handle_call({:get_public_key, key_set_url, kid}, _from, state) do
    case get_cached_key(state, key_set_url, kid) do
      {:ok, key, new_state} ->
        {:reply, {:ok, key}, new_state}

      {:cache_miss, new_state} ->
        case fetch_and_cache_keys(key_set_url, new_state) do
          {:ok, updated_state} ->
            case get_cached_key(updated_state, key_set_url, kid) do
              {:ok, key, final_state} ->
                {:reply, {:ok, key}, final_state}

              {:cache_miss, final_state} ->
                {:reply, return_key_not_found(kid), final_state}
            end

          {:error, reason, error_state} ->
            {:reply, {:error, reason}, error_state}
        end
    end
  end

  @impl GenServer
  def handle_call({:preload_keys, key_set_url}, _from, state) do
    case fetch_and_cache_keys(key_set_url, state) do
      {:ok, new_state} ->
        {:reply, :ok, new_state}

      {:error, reason, error_state} ->
        {:reply, {:error, reason}, error_state}
    end
  end

  @impl GenServer
  def handle_call(:refresh_all_keys, _from, state) do
    {results, new_state} = refresh_all_cached_keys(state)
    {:reply, results, new_state}
  end

  @impl GenServer
  def handle_call(:clear_cache, _from, state) do
    new_state = %{state | cache: %{}}
    {:reply, :ok, new_state}
  end

  @impl GenServer
  def handle_call(:cache_info, _from, state) do
    info = %{
      cached_urls: Map.keys(state.cache),
      cache_entries_count: map_size(state.cache),
      total_cached_keys:
        state.cache
        |> Map.values()
        |> Enum.map(fn entry -> map_size(entry.keys) end)
        |> Enum.sum(),
      cache_hits: state.cache_hits,
      cache_misses: state.cache_misses,
      refresh_errors: state.refresh_errors,
      hit_rate: calculate_hit_rate(state.cache_hits, state.cache_misses)
    }

    {:reply, info, state}
  end

  @impl GenServer
  def handle_cast(:refresh_stale_keys, state) do
    {_results, new_state} = refresh_stale_cached_keys(state)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_info({:refresh_timer, interval}, state) do
    {_results, new_state} = refresh_stale_cached_keys(state)
    schedule_refresh(interval)
    {:noreply, new_state}
  end

  ## Private Functions

  defp get_cached_key(state, key_set_url, kid) do
    case Map.get(state.cache, key_set_url) do
      nil ->
        {:cache_miss, %{state | cache_misses: state.cache_misses + 1}}

      %CacheEntry{} = entry ->
        if DateTime.after?(DateTime.utc_now(), entry.expires_at) do
          # Entry is expired
          {:cache_miss, %{state | cache_misses: state.cache_misses + 1}}
        else
          case Map.get(entry.keys, kid) do
            nil ->
              {:cache_miss, %{state | cache_misses: state.cache_misses + 1}}

            key ->
              {:ok, key, %{state | cache_hits: state.cache_hits + 1}}
          end
        end
    end
  end

  defp fetch_and_cache_keys(key_set_url, state) do
    case fetch_keys_from_url(key_set_url) do
      {:ok, keys, cache_info} ->
        entry = %CacheEntry{
          keys: keys,
          expires_at: calculate_expires_at(cache_info),
          cache_control: cache_info[:cache_control],
          last_modified: cache_info[:last_modified],
          etag: cache_info[:etag]
        }

        new_cache = Map.put(state.cache, key_set_url, entry)
        {:ok, %{state | cache: new_cache}}

      {:error, reason} ->
        Logger.error("Failed to fetch keys from #{key_set_url}: #{inspect(reason)}")

        error_state = %{state | refresh_errors: state.refresh_errors + 1}
        {:error, reason, error_state}
    end
  end

  defp fetch_keys_from_url(key_set_url) do
    case http_client!().get(key_set_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        case Jason.decode(body) do
          {:ok, %{"keys" => raw_keys}} when is_list(raw_keys) ->
            keys =
              raw_keys
              |> Enum.filter(&is_map/1)
              |> Enum.filter(fn key -> Map.has_key?(key, "kid") end)
              |> Enum.map(fn key_json ->
                key =
                  key_json
                  |> convert_map_to_base64url()
                  |> JOSE.JWK.from()

                {key_json["kid"], key}
              end)
              |> Enum.into(%{})

            cache_info = extract_cache_info(headers)
            {:ok, keys, cache_info}

          {:ok, _invalid_format} ->
            {:error, %{reason: :invalid_key_set_format, msg: "Invalid key set format"}}

          {:error, _decode_error} ->
            {:error, %{reason: :invalid_json, msg: "Invalid JSON in key set response"}}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, %{reason: :http_error, msg: "HTTP #{status_code} when fetching key set"}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{reason: :http_error, msg: "HTTP error: #{inspect(reason)}"}}

      error ->
        {:error, %{reason: :unknown_error, msg: "Unknown error: #{inspect(error)}"}}
    end
  end

  defp extract_cache_info(headers) do
    headers_map =
      headers
      |> Enum.map(fn {k, v} -> {String.downcase(k), v} end)
      |> Enum.into(%{})

    %{
      cache_control: headers_map["cache-control"],
      last_modified: headers_map["last-modified"],
      etag: headers_map["etag"],
      expires: headers_map["expires"]
    }
  end

  defp calculate_expires_at(cache_info) do
    default_ttl = get_cache_ttl()

    cond do
      cache_info[:cache_control] ->
        parse_cache_control_max_age(cache_info[:cache_control], default_ttl)

      cache_info[:expires] ->
        parse_expires_header(cache_info[:expires], default_ttl)

      true ->
        DateTime.add(DateTime.utc_now(), default_ttl, :second)
    end
  end

  defp parse_cache_control_max_age(cache_control, default_ttl) do
    case Regex.run(~r/max-age=(\d+)/, cache_control) do
      [_, max_age_str] ->
        case Integer.parse(max_age_str) do
          {max_age, _} when max_age > 0 ->
            DateTime.add(DateTime.utc_now(), max_age, :second)

          _ ->
            DateTime.add(DateTime.utc_now(), default_ttl, :second)
        end

      _ ->
        DateTime.add(DateTime.utc_now(), default_ttl, :second)
    end
  end

  defp parse_expires_header(expires, default_ttl) do
    case DateTime.from_iso8601(expires) do
      {:ok, expires_dt, _} ->
        expires_dt

      _ ->
        # Try HTTP date format
        case Timex.parse(expires, "{RFC1123}") do
          {:ok, expires_dt} ->
            expires_dt

          _ ->
            DateTime.add(DateTime.utc_now(), default_ttl, :second)
        end
    end
  end

  defp refresh_all_cached_keys(state) do
    {results, final_state} =
      state.cache
      |> Enum.reduce({[], state}, fn {key_set_url, _entry}, {acc_results, acc_state} ->
        case fetch_and_cache_keys(key_set_url, acc_state) do
          {:ok, new_state} ->
            {[{key_set_url, :ok} | acc_results], new_state}

          {:error, reason, error_state} ->
            {[{key_set_url, {:error, reason}} | acc_results], error_state}
        end
      end)

    {Enum.reverse(results), final_state}
  end

  defp refresh_stale_cached_keys(state) do
    now = DateTime.utc_now()

    stale_entries =
      state.cache
      |> Enum.filter(fn {_url, entry} ->
        DateTime.after?(now, entry.expires_at)
      end)

    {results, final_state} =
      stale_entries
      |> Enum.reduce({[], state}, fn {key_set_url, _entry}, {acc_results, acc_state} ->
        case fetch_and_cache_keys(key_set_url, acc_state) do
          {:ok, new_state} ->
            {[{key_set_url, :ok} | acc_results], new_state}

          {:error, reason, error_state} ->
            {[{key_set_url, {:error, reason}} | acc_results], error_state}
        end
      end)

    {Enum.reverse(results), final_state}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), {:refresh_timer, interval}, interval * 1000)
  end

  defp get_cache_ttl() do
    Lti_1p3.Config.get(:key_provider_cache_ttl, @default_cache_ttl)
  end

  defp calculate_hit_rate(hits, misses) when hits + misses > 0 do
    Float.round(hits / (hits + misses) * 100, 2)
  end

  defp calculate_hit_rate(_, _), do: 0.0

  defp return_key_not_found(kid) do
    {:error,
     %{
       reason: :key_not_found,
       msg: "Key with kid #{kid} not found in the fetched list of public keys"
     }}
  end
end
