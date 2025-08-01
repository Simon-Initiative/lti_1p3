defmodule Lti_1p3.KeyProviders.MemoryKeyProviderTest do
  use ExUnit.Case, async: false

  import Mox
  import Lti_1p3.Test.TestHelpers

  alias Lti_1p3.KeyProviders.MemoryKeyProvider
  alias Lti_1p3.Test.MockHTTPoison

  setup do
    # Start the data provider for jwk_fixture (if not already started)
    {:ok, initial_state} = Lti_1p3.DataProviders.MemoryProvider.init()

    case Lti_1p3.DataProviders.MemoryProvider.start_link(initial_state) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end

    # Setup HTTP client
    Application.put_env(:lti_1p3, :http_client, MockHTTPoison)

    :ok
  end

  setup :verify_on_exit!
  setup :set_mox_from_context

  setup do
    # Start a test instance of the key provider
    {:ok, pid} = MemoryKeyProvider.start_link(refresh_interval: 0)

    # Allow the key provider process to use the mock
    Mox.allow(MockHTTPoison, self(), pid)

    # Clear any existing cache
    MemoryKeyProvider.clear_cache()

    on_exit(fn ->
      if Process.alive?(pid) do
        GenServer.stop(pid)
      end
    end)

    %{key_provider: pid}
  end

  describe "get_public_key/2" do
    test "fetches and caches keys from key set URL" do
      jwk = jwk_fixture()
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        mock_get_jwk_keys(jwk)
      end)

      assert {:ok, public_key} = MemoryKeyProvider.get_public_key(key_set_url, jwk.kid)
      assert %JOSE.JWK{} = public_key

      # Second call should hit cache (no HTTP call expected)
      assert {:ok, ^public_key} = MemoryKeyProvider.get_public_key(key_set_url, jwk.kid)
    end

    test "returns error when key not found" do
      jwk = jwk_fixture()
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        mock_get_jwk_keys(jwk)
      end)

      assert {:error, %{reason: :key_not_found}} =
               MemoryKeyProvider.get_public_key(key_set_url, "non-existent-kid")
    end

    test "returns error when HTTP request fails" do
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      assert {:error, %{reason: :http_error}} =
               MemoryKeyProvider.get_public_key(key_set_url, "some-kid")
    end

    test "returns error when response is not 200" do
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        {:ok, %HTTPoison.Response{status_code: 404, body: "Not Found"}}
      end)

      assert {:error, %{reason: :http_error}} =
               MemoryKeyProvider.get_public_key(key_set_url, "some-kid")
    end

    test "returns error when response body is invalid JSON" do
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        {:ok, %HTTPoison.Response{status_code: 200, body: "invalid json"}}
      end)

      assert {:error, %{reason: :invalid_json}} =
               MemoryKeyProvider.get_public_key(key_set_url, "some-kid")
    end

    test "returns error when key set format is invalid" do
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        body = Jason.encode!(%{"invalid" => "format"})
        {:ok, %HTTPoison.Response{status_code: 200, body: body}}
      end)

      assert {:error, %{reason: :invalid_key_set_format}} =
               MemoryKeyProvider.get_public_key(key_set_url, "some-kid")
    end
  end

  describe "preload_keys/1" do
    test "preloads keys from key set URL" do
      jwk = jwk_fixture()
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        mock_get_jwk_keys(jwk)
      end)

      assert :ok = MemoryKeyProvider.preload_keys(key_set_url)

      # Subsequent call should hit cache
      assert {:ok, _public_key} = MemoryKeyProvider.get_public_key(key_set_url, jwk.kid)
    end

    test "returns error when preload fails" do
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      assert {:error, %{reason: :http_error}} = MemoryKeyProvider.preload_keys(key_set_url)
    end
  end

  describe "refresh_all_keys/0" do
    test "refreshes all cached keys" do
      jwk1 = jwk_fixture()
      jwk2 = jwk_fixture()
      key_set_url1 = "https://example1.com/.well-known/jwks.json"
      key_set_url2 = "https://example2.com/.well-known/jwks.json"

      # Initial load
      MockHTTPoison
      |> expect(:get, fn ^key_set_url1 -> mock_get_jwk_keys(jwk1) end)
      |> expect(:get, fn ^key_set_url2 -> mock_get_jwk_keys(jwk2) end)

      MemoryKeyProvider.preload_keys(key_set_url1)
      MemoryKeyProvider.preload_keys(key_set_url2)

      # Refresh
      MockHTTPoison
      |> expect(:get, fn ^key_set_url1 -> mock_get_jwk_keys(jwk1) end)
      |> expect(:get, fn ^key_set_url2 -> mock_get_jwk_keys(jwk2) end)

      results = MemoryKeyProvider.refresh_all_keys()
      assert length(results) == 2
      assert Enum.all?(results, fn {_url, result} -> result == :ok end)
    end
  end

  describe "clear_cache/0" do
    test "clears all cached keys" do
      jwk = jwk_fixture()
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url -> mock_get_jwk_keys(jwk) end)

      MemoryKeyProvider.preload_keys(key_set_url)
      assert :ok = MemoryKeyProvider.clear_cache()

      info = MemoryKeyProvider.cache_info()
      assert info.cache_entries_count == 0
    end
  end

  describe "cache_info/0" do
    test "returns cache information" do
      info = MemoryKeyProvider.cache_info()

      assert is_map(info)
      assert Map.has_key?(info, :cached_urls)
      assert Map.has_key?(info, :cache_entries_count)
      assert Map.has_key?(info, :total_cached_keys)
      assert Map.has_key?(info, :cache_hits)
      assert Map.has_key?(info, :cache_misses)
      assert Map.has_key?(info, :refresh_errors)
      assert Map.has_key?(info, :hit_rate)
    end

    test "tracks cache hits and misses" do
      jwk = jwk_fixture()
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url -> mock_get_jwk_keys(jwk) end)

      # Cache miss
      MemoryKeyProvider.get_public_key(key_set_url, jwk.kid)

      # Cache hit
      MemoryKeyProvider.get_public_key(key_set_url, jwk.kid)

      info = MemoryKeyProvider.cache_info()
      assert info.cache_hits >= 1
      assert info.cache_misses >= 1
    end
  end

  describe "cache expiration" do
    test "respects cache-control max-age header" do
      jwk = jwk_fixture()
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        body =
          Jason.encode!(%{
            "keys" => [
              jwk.pem
              |> JOSE.JWK.from_pem()
              |> JOSE.JWK.to_public()
              |> JOSE.JWK.to_map()
              |> (fn {_kty, public_jwk} -> public_jwk end).()
              |> Map.put("typ", jwk.typ)
              |> Map.put("alg", jwk.alg)
              |> Map.put("kid", jwk.kid)
              |> Map.put("use", "sig")
            ]
          })

        headers = [{"cache-control", "max-age=60"}]
        {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}}
      end)

      assert {:ok, _} = MemoryKeyProvider.get_public_key(key_set_url, jwk.kid)

      # Key should be cached
      info = MemoryKeyProvider.cache_info()
      assert info.cache_entries_count == 1
    end
  end
end
