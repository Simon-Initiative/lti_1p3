defmodule Lti_1p3 do
  import Lti_1p3.Config

  alias Lti_1p3.Jwk

  @doc """
  Creates a new jwk.
  ## Examples
      iex> create_jwk(%Jwk{})
      {:ok, %Jwk{}}
      iex> create_jwk(%Jwk{})
      {:error, %Lti_1p3.DataProviderError{}}
  """
  def create_jwk(%Jwk{} = jwk), do: provider!().create_jwk(jwk)

  @doc """
  Gets the currently active Jwk.
  If there are more that one active Jwk, this will return the first one it finds
  ## Examples
      iex> get_active_jwk()
      {:ok, %Lti_1p3.Jwk{}}
      iex> get_active_jwk()
      {:error, %Lti_1p3.DataProviderError{}}
  """
  def get_active_jwk(), do: provider!().get_active_jwk()

  @doc """
  Gets a all public keys.
  ## Examples
      iex> get_all_public_keys()
      %{keys: []}
  """
  def get_all_public_keys() do
    public_keys =
      provider!().get_all_jwks()
      |> Enum.map(fn %{pem: pem, typ: typ, alg: alg, kid: kid} ->
        pem
        |> JOSE.JWK.from_pem()
        |> JOSE.JWK.to_public()
        |> JOSE.JWK.to_map()
        |> (fn {_kty, public_jwk} -> public_jwk end).()
        |> Map.put("typ", typ)
        |> Map.put("alg", alg)
        |> Map.put("kid", kid)
        |> Map.put("use", "sig")
      end)

    %{keys: public_keys}
  end

  @doc """
  Preloads keys from the given key set URL into the key provider cache.

  This is useful for warming up the cache before LTI launches.

  ## Examples
      iex> preload_keys("https://platform.example.edu/.well-known/jwks.json")
      :ok
      iex> preload_keys("https://invalid-url")
      {:error, %{reason: :http_error, msg: "..."}}
  """
  def preload_keys(key_set_url) do
    key_provider_module = key_provider!()
    key_provider_module.preload_keys(key_set_url)
  end

  @doc """
  Gets a public key from the key provider cache.

  ## Examples
      iex> get_public_key("https://platform.example.edu/.well-known/jwks.json", "key-123")
      {:ok, %JOSE.JWK{}}
      iex> get_public_key("https://platform.example.edu/.well-known/jwks.json", "not-found")
      {:error, %{reason: :key_not_found, msg: "..."}}
  """
  def get_public_key(key_set_url, kid) do
    key_provider_module = key_provider!()
    key_provider_module.get_public_key(key_set_url, kid)
  end

  @doc """
  Refreshes all cached keys in the key provider.

  ## Examples
      iex> refresh_all_keys()
      [{"https://platform.example.edu/.well-known/jwks.json", :ok}]
  """
  def refresh_all_keys() do
    key_provider_module = key_provider!()
    key_provider_module.refresh_all_keys()
  end

  @doc """
  Clears all cached keys in the key provider.

  This is mainly useful for testing.

  ## Examples
      iex> clear_key_cache()
      :ok
  """
  def clear_key_cache() do
    key_provider_module = key_provider!()
    key_provider_module.clear_cache()
  end

  @doc """
  Gets information about the key provider cache.

  ## Examples
      iex> key_cache_info()
      %{
        cached_urls: ["https://platform.example.edu/.well-known/jwks.json"],
        cache_entries_count: 1,
        total_cached_keys: 3,
        cache_hits: 42,
        cache_misses: 5,
        refresh_errors: 0,
        hit_rate: 89.36
      }
  """
  def key_cache_info() do
    key_provider_module = key_provider!()
    key_provider_module.cache_info()
  end
end
