defmodule Lti_1p3.KeyProviderIntegrationTest do
  use ExUnit.Case, async: false

  import Mox
  import Lti_1p3.Test.TestHelpers

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
    # Start the key provider supervisor for testing
    {:ok, supervisor_pid} =
      Lti_1p3.KeyProviderSupervisor.start_link(
        key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
        # Disable automatic refresh for tests
        refresh_interval: 0
      )

    # Get the child process (MemoryKeyProvider) and allow it to use the mock
    [
      {Lti_1p3.KeyProviders.MemoryKeyProvider, child_pid, :worker,
       [Lti_1p3.KeyProviders.MemoryKeyProvider]}
    ] =
      Supervisor.which_children(supervisor_pid)

    Mox.allow(MockHTTPoison, self(), child_pid)

    # Clear cache before each test using the direct module call
    # since the supervisor starts the key provider automatically
    Lti_1p3.KeyProviders.MemoryKeyProvider.clear_cache()

    on_exit(fn ->
      if Process.alive?(supervisor_pid) do
        Process.exit(supervisor_pid, :normal)
      end
    end)

    :ok
  end

  describe "preload_keys/1" do
    test "preloads keys using the configured key provider" do
      jwk = jwk_fixture()
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        mock_get_jwk_keys(jwk)
      end)

      assert :ok = Lti_1p3.preload_keys(key_set_url)

      # Verify keys are cached
      info = Lti_1p3.key_cache_info()
      assert info.cache_entries_count == 1
      assert key_set_url in info.cached_urls
    end
  end

  describe "get_public_key/2" do
    test "gets public key using the configured key provider" do
      jwk = jwk_fixture()
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        mock_get_jwk_keys(jwk)
      end)

      assert {:ok, public_key} = Lti_1p3.get_public_key(key_set_url, jwk.kid)
      assert %JOSE.JWK{} = public_key
    end
  end

  describe "refresh_all_keys/0" do
    test "refreshes all keys using the configured key provider" do
      jwk = jwk_fixture()
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url -> mock_get_jwk_keys(jwk) end)
      |> expect(:get, fn ^key_set_url -> mock_get_jwk_keys(jwk) end)

      # Preload first
      Lti_1p3.preload_keys(key_set_url)

      # Then refresh
      results = Lti_1p3.refresh_all_keys()
      assert [{^key_set_url, :ok}] = results
    end
  end

  describe "clear_key_cache/0" do
    test "clears cache using the configured key provider" do
      jwk = jwk_fixture()
      key_set_url = "https://example.com/.well-known/jwks.json"

      MockHTTPoison
      |> expect(:get, fn ^key_set_url ->
        mock_get_jwk_keys(jwk)
      end)

      Lti_1p3.preload_keys(key_set_url)
      assert :ok = Lti_1p3.clear_key_cache()

      info = Lti_1p3.key_cache_info()
      assert info.cache_entries_count == 0
    end
  end

  describe "key_cache_info/0" do
    test "returns cache info from the configured key provider" do
      info = Lti_1p3.key_cache_info()

      assert is_map(info)
      assert Map.has_key?(info, :cached_urls)
      assert Map.has_key?(info, :cache_entries_count)
      assert Map.has_key?(info, :total_cached_keys)
      assert Map.has_key?(info, :cache_hits)
      assert Map.has_key?(info, :cache_misses)
      assert Map.has_key?(info, :refresh_errors)
      assert Map.has_key?(info, :hit_rate)
    end
  end
end
