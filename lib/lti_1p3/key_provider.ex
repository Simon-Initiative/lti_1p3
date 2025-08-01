defmodule Lti_1p3.KeyProvider do
  @moduledoc """
  Behaviour for implementing key providers that fetch and cache public keys from key set URLs.

  Key providers are responsible for fetching, caching, and refreshing public keys
  from platform key set URLs. This allows for better performance and reliability
  compared to fetching keys on every request.
  """

  @doc """
  Fetches a public key for the given key set URL and key ID (kid).

  Returns the public key if found, or an error if the key is not available.
  """
  @callback get_public_key(key_set_url :: String.t(), kid :: String.t()) ::
              {:ok, JOSE.JWK.t()} | {:error, %{reason: atom(), msg: String.t()}}

  @doc """
  Preloads keys from the given key set URL.

  This is useful for warming up the cache or ensuring keys are available
  before they're needed.
  """
  @callback preload_keys(key_set_url :: String.t()) ::
              :ok | {:error, %{reason: atom(), msg: String.t()}}

  @doc """
  Refreshes all cached keys.

  This should be called periodically to ensure cached keys are up to date.
  Returns a list of {key_set_url, result} tuples indicating which URLs
  were refreshed and their results.
  """
  @callback refresh_all_keys() :: [
              {String.t(), :ok | {:error, %{reason: atom(), msg: String.t()}}}
            ]

  @doc """
  Clears all cached keys.

  This is useful for testing or when cache needs to be invalidated.
  """
  @callback clear_cache() :: :ok

  @doc """
  Returns information about the current cache state.

  This can include metrics like cache hit rates, number of cached keys,
  last refresh times, etc.
  """
  @callback cache_info() :: map()
end
