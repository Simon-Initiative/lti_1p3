defmodule Lti_1p3.DataProviders.MemoryProvider do
  @moduledoc """
  Reference in-memory provider implementation backed by an `Agent`.
  """

  alias Lti_1p3.DataProvider
  alias Lti_1p3.DataProviderError
  alias Lti_1p3.Jwk
  alias Lti_1p3.Nonce
  alias Lti_1p3.Platform.Services.AGS.LineItem
  alias Lti_1p3.Platform.Services.AGS.Result
  alias Lti_1p3.Platform.Services.AGS.Score
  alias Lti_1p3.Platform.LoginHint
  alias Lti_1p3.Platform.PlatformInstance
  alias Lti_1p3.PlatformDataProvider
  alias Lti_1p3.Tool.Deployment
  alias Lti_1p3.Tool.Registration
  alias Lti_1p3.ToolDataProvider

  @behaviour DataProvider
  @behaviour ToolDataProvider
  @behaviour PlatformDataProvider

  @spec init(any()) :: {:ok, map()}
  def init(_opts \\ []) do
    {:ok, initial_state()}
  end

  @spec initial_state() :: map()
  def initial_state do
    %{
      index_counters: %{},
      jwks: [],
      nonces: %{},
      registrations: %{},
      deployments: [],
      platform_instances: %{},
      login_hints: %{},
      ags_line_items: %{},
      ags_scores: %{}
    }
  end

  @spec start_link(map()) :: Agent.on_start()
  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  @impl DataProvider
  def create_jwk(%Jwk{} = jwk) do
    jwk = Map.put(jwk, :id, get_next_index(:jwk))
    Agent.update(__MODULE__, fn state -> %{state | jwks: state.jwks ++ [jwk]} end)
    {:ok, jwk}
  end

  @impl DataProvider
  def get_active_jwk do
    active_jwk =
      Agent.get(__MODULE__, fn state ->
        Enum.find(state.jwks, &(&1.active == true))
      end)

    case active_jwk do
      nil -> {:error, %DataProviderError{msg: "No active Jwk", reason: :not_found}}
      _ -> {:ok, active_jwk}
    end
  end

  @impl DataProvider
  def get_all_jwks do
    Agent.get(__MODULE__, & &1.jwks)
  end

  @impl DataProvider
  def create_nonce(%Nonce{} = nonce) do
    nonce =
      nonce
      |> Map.from_struct()
      |> Map.put(:inserted_at, Timex.now())
      |> Map.put(:id, get_next_index(:nonce))

    case get_nonce(nonce.value, nonce.domain) do
      nil ->
        Agent.update(__MODULE__, fn state ->
          %{state | nonces: Map.put_new(state.nonces, nonce_key(nonce), nonce)}
        end)

        {:ok, struct(Nonce, nonce)}

      _ ->
        {:error,
         %DataProviderError{
           msg: "Nonce with value already exists",
           reason: :unique_constraint_violation
         }}
    end
  end

  @impl DataProvider
  def get_nonce(value, domain \\ nil) do
    Agent.get(__MODULE__, fn state ->
      case Map.get(state.nonces, nonce_key(%{value: value, domain: domain})) do
        nil -> nil
        nonce -> struct(Nonce, nonce)
      end
    end)
  end

  @impl DataProvider
  def delete_expired_nonces(nonce_ttl_sec \\ 86_400) do
    nonce_expiry = Timex.now() |> Timex.subtract(Timex.Duration.from_seconds(nonce_ttl_sec))

    Agent.update(__MODULE__, fn state ->
      filtered_nonces =
        Enum.reduce(state.nonces, %{}, fn {key, nonce}, acc ->
          if nonce.inserted_at > nonce_expiry, do: Map.put(acc, key, nonce), else: acc
        end)

      %{state | nonces: filtered_nonces}
    end)
  end

  @impl ToolDataProvider
  def create_registration(%Registration{issuer: issuer, client_id: client_id} = registration) do
    registration = Map.put(registration, :id, get_next_index(:registration))

    Agent.update(__MODULE__, fn state ->
      %{
        state
        | registrations:
            Map.put(state.registrations, registration_key(issuer, client_id), registration)
      }
    end)

    {:ok, registration}
  end

  @impl ToolDataProvider
  def create_deployment(%Deployment{} = deployment) do
    deployment = Map.put(deployment, :id, get_next_index(:deployment))

    Agent.update(__MODULE__, fn state ->
      %{state | deployments: state.deployments ++ [deployment]}
    end)

    {:ok, deployment}
  end

  @impl ToolDataProvider
  def get_registration_deployment(issuer, client_id, deployment_id) do
    registration = get_registration_by_issuer_client_id(issuer, client_id)

    case registration do
      nil ->
        {nil, nil}

      registration ->
        deployment =
          Agent.get(__MODULE__, fn state ->
            Enum.find(state.deployments, fn d ->
              d.registration_id == registration.id and d.deployment_id == deployment_id
            end)
          end)

        {registration, deployment}
    end
  end

  @impl ToolDataProvider
  def get_jwk_by_registration(%Registration{tool_jwk_id: tool_jwk_id}) do
    jwk = Agent.get(__MODULE__, fn state -> Enum.find(state.jwks, &(&1.id == tool_jwk_id)) end)

    case jwk do
      nil -> {:error, %DataProviderError{msg: "Jwk not found", reason: :not_found}}
      _ -> {:ok, jwk}
    end
  end

  @impl ToolDataProvider
  def get_registration_by_issuer_client_id(issuer, client_id) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state.registrations, registration_key(issuer, client_id))
    end)
  end

  @impl ToolDataProvider
  def get_deployment(%Registration{id: registration_id}, deployment_id) do
    Agent.get(__MODULE__, fn state ->
      Enum.find(state.deployments, fn d ->
        d.registration_id == registration_id and d.deployment_id == deployment_id
      end)
    end)
  end

  @impl PlatformDataProvider
  def create_platform_instance(%PlatformInstance{client_id: client_id} = platform_instance) do
    platform_instance = Map.put(platform_instance, :id, get_next_index(:platform_instance))

    Agent.update(__MODULE__, fn state ->
      %{
        state
        | platform_instances: Map.put_new(state.platform_instances, client_id, platform_instance)
      }
    end)

    {:ok, platform_instance}
  end

  @impl PlatformDataProvider
  def get_platform_instance_by_client_id(client_id) do
    Agent.get(__MODULE__, fn state -> Map.get(state.platform_instances, client_id) end)
  end

  @impl PlatformDataProvider
  def get_login_hint_by_value(value) do
    Agent.get(__MODULE__, fn state -> Map.get(state.login_hints, value) end)
  end

  @impl PlatformDataProvider
  def create_login_hint(%LoginHint{value: value} = login_hint) do
    login_hint =
      login_hint
      |> Map.put(:inserted_at, Timex.now())
      |> Map.put(:id, get_next_index(:login_hint))

    Agent.update(__MODULE__, fn state ->
      %{state | login_hints: Map.put_new(state.login_hints, value, login_hint)}
    end)

    {:ok, login_hint}
  end

  @impl PlatformDataProvider
  def delete_expired_login_hints(login_hint_ttl_sec \\ 86_400) do
    login_hint_expiry =
      Timex.now() |> Timex.subtract(Timex.Duration.from_seconds(login_hint_ttl_sec))

    Agent.update(__MODULE__, fn state ->
      filtered_hints =
        Enum.reduce(state.login_hints, %{}, fn {key, login_hint}, acc ->
          if login_hint.inserted_at > login_hint_expiry,
            do: Map.put(acc, key, login_hint),
            else: acc
        end)

      %{state | login_hints: filtered_hints}
    end)
  end

  @impl PlatformDataProvider
  def list_ags_line_items(deployment_id, context_id, filters) do
    line_items =
      Agent.get(__MODULE__, fn state ->
        state
        |> Map.get(:ags_line_items, %{})
        |> Map.get(ags_key(deployment_id, context_id), %{})
        |> Map.values()
      end)
      |> Enum.sort_by(& &1.id)
      |> maybe_filter_line_items(filters)
      |> maybe_limit(filters)

    {:ok, line_items}
  end

  @impl PlatformDataProvider
  def create_ags_line_item(deployment_id, context_id, attrs) do
    line_item_id = Map.get(attrs, :id, "line-item-#{get_next_index(:ags_line_item)}")

    line_item =
      struct(LineItem, %{
        id: line_item_id,
        scoreMaximum: Map.get(attrs, :scoreMaximum),
        label: Map.get(attrs, :label),
        resourceId: Map.get(attrs, :resourceId),
        tag: Map.get(attrs, :tag),
        resourceLinkId: Map.get(attrs, :resourceLinkId)
      })

    key = ags_key(deployment_id, context_id)

    Agent.get_and_update(__MODULE__, fn state ->
      line_items_by_context = Map.get(state, :ags_line_items, %{})
      line_items = Map.get(line_items_by_context, key, %{})

      if Map.has_key?(line_items, line_item.id) do
        {{:error, :already_exists}, state}
      else
        updated_line_items_by_context =
          Map.put(line_items_by_context, key, Map.put(line_items, line_item.id, line_item))

        {{:ok, line_item}, %{state | ags_line_items: updated_line_items_by_context}}
      end
    end)
  end

  @impl PlatformDataProvider
  def get_ags_line_item(deployment_id, context_id, id_or_url) do
    line_item_id = normalize_line_item_id(id_or_url)
    key = ags_key(deployment_id, context_id)

    line_item =
      Agent.get(__MODULE__, fn state ->
        state
        |> Map.get(:ags_line_items, %{})
        |> Map.get(key, %{})
        |> Map.get(line_item_id)
      end)

    case line_item do
      %LineItem{} = item -> {:ok, item}
      nil -> {:error, {:not_found, :line_item, line_item_id}}
    end
  end

  @impl PlatformDataProvider
  def update_ags_line_item(deployment_id, context_id, id_or_url, attrs) do
    line_item_id = normalize_line_item_id(id_or_url)
    key = ags_key(deployment_id, context_id)

    Agent.get_and_update(__MODULE__, fn state ->
      line_items_by_context = Map.get(state, :ags_line_items, %{})
      line_items = Map.get(line_items_by_context, key, %{})

      case Map.get(line_items, line_item_id) do
        nil ->
          {{:error, {:not_found, :line_item, line_item_id}}, state}

        line_item ->
          updated_line_item =
            struct(line_item, %{
              scoreMaximum: Map.get(attrs, :scoreMaximum, line_item.scoreMaximum),
              label: Map.get(attrs, :label, line_item.label),
              resourceId: Map.get(attrs, :resourceId, line_item.resourceId),
              tag: Map.get(attrs, :tag, line_item.tag),
              resourceLinkId: Map.get(attrs, :resourceLinkId, line_item.resourceLinkId)
            })

          updated_line_items_by_context =
            Map.put(
              line_items_by_context,
              key,
              Map.put(line_items, line_item_id, updated_line_item)
            )

          {{:ok, updated_line_item}, %{state | ags_line_items: updated_line_items_by_context}}
      end
    end)
  end

  @impl PlatformDataProvider
  def delete_ags_line_item(deployment_id, context_id, id_or_url) do
    line_item_id = normalize_line_item_id(id_or_url)
    key = ags_key(deployment_id, context_id)

    case Agent.get_and_update(__MODULE__, fn state ->
           line_items_by_context = Map.get(state, :ags_line_items, %{})
           line_items = Map.get(line_items_by_context, key, %{})

           if Map.has_key?(line_items, line_item_id) do
             updated_line_items_by_context =
               Map.put(line_items_by_context, key, Map.delete(line_items, line_item_id))

             scores_by_context = Map.get(state, :ags_scores, %{})
             context_scores = Map.get(scores_by_context, key, %{})
             updated_context_scores = Map.delete(context_scores, line_item_id)
             updated_scores_by_context = Map.put(scores_by_context, key, updated_context_scores)

             {{:ok, :deleted},
              %{
                state
                | ags_line_items: updated_line_items_by_context,
                  ags_scores: updated_scores_by_context
              }}
           else
             {{:error, {:not_found, :line_item, line_item_id}}, state}
           end
         end) do
      {:ok, :deleted} -> :ok
      error -> error
    end
  end

  @impl PlatformDataProvider
  def create_ags_score(deployment_id, context_id, id_or_url, %Score{} = score) do
    line_item_id = normalize_line_item_id(id_or_url)
    key = ags_key(deployment_id, context_id)

    case Agent.get_and_update(__MODULE__, fn state ->
           line_items_by_context = Map.get(state, :ags_line_items, %{})
           line_items = Map.get(line_items_by_context, key, %{})

           if Map.has_key?(line_items, line_item_id) do
             scores_by_context = Map.get(state, :ags_scores, %{})
             context_scores = Map.get(scores_by_context, key, %{})
             scores = Map.get(context_scores, line_item_id, [])

             updated_scores_by_context =
               Map.put(
                 scores_by_context,
                 key,
                 Map.put(context_scores, line_item_id, scores ++ [score])
               )

             {{:ok, :created}, %{state | ags_scores: updated_scores_by_context}}
           else
             {{:error, {:not_found, :line_item, line_item_id}}, state}
           end
         end) do
      {:ok, :created} -> :ok
      error -> error
    end
  end

  @impl PlatformDataProvider
  def list_ags_results(deployment_id, context_id, id_or_url, filters) do
    line_item_id = normalize_line_item_id(id_or_url)
    key = ags_key(deployment_id, context_id)

    Agent.get(__MODULE__, fn state ->
      line_items_by_context = Map.get(state, :ags_line_items, %{})
      line_items = Map.get(line_items_by_context, key, %{})

      case Map.get(line_items, line_item_id) do
        nil ->
          {:error, {:not_found, :line_item, line_item_id}}

        line_item ->
          scores =
            state
            |> Map.get(:ags_scores, %{})
            |> Map.get(key, %{})
            |> Map.get(line_item_id, [])

          results =
            scores
            |> Enum.map(fn score ->
              %Result{
                userId: score.userId,
                resultScore: score.scoreGiven,
                resultMaximum: score.scoreMaximum || line_item.scoreMaximum,
                comment: score.comment
              }
            end)
            |> maybe_filter_results(filters)
            |> maybe_limit(filters)

          {:ok, results}
      end
    end)
  end

  @doc false
  def nonce_key(%{value: value, domain: nil}), do: value
  def nonce_key(%{value: value, domain: domain}), do: value <> domain

  defp registration_key(issuer, client_id), do: issuer <> client_id
  defp ags_key(deployment_id, context_id), do: deployment_id <> "::" <> context_id

  defp normalize_line_item_id(id_or_url) do
    case URI.parse(id_or_url) do
      %URI{path: path} when is_binary(path) and path != "" ->
        path
        |> String.trim_trailing("/")
        |> String.split("/")
        |> List.last()
        |> case do
          nil -> id_or_url
          "" -> id_or_url
          segment -> segment
        end

      _ ->
        id_or_url
    end
  end

  defp maybe_filter_line_items(items, filters) do
    Enum.filter(items, fn item ->
      resource_id = Map.get(filters, "resource_id")
      tag = Map.get(filters, "tag")

      matches_resource_id? = is_nil(resource_id) or to_string(item.resourceId) == resource_id
      matches_tag? = is_nil(tag) or item.tag == tag
      matches_resource_id? and matches_tag?
    end)
  end

  defp maybe_filter_results(results, filters) do
    case Map.get(filters, "user_id") do
      nil -> results
      user_id -> Enum.filter(results, &(&1.userId == user_id))
    end
  end

  defp maybe_limit(items, filters) do
    case Map.get(filters, "limit") do
      nil -> items
      limit when is_binary(limit) -> Enum.take(items, String.to_integer(limit))
      _ -> items
    end
  end

  defp get_next_index(type) do
    next_index = Agent.get(__MODULE__, fn state -> Map.get(state.index_counters, type, 0) end)

    Agent.update(__MODULE__, fn state ->
      %{state | index_counters: Map.put(state.index_counters, type, next_index + 1)}
    end)

    next_index
  end
end
