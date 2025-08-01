defmodule Lti_1p3.Examples.KeyProviderConfig do
  @moduledoc """
  Example configuration for the LTI 1.3 key provider.

  This module provides example configurations that client applications can use
  as a reference when setting up the key provider in their supervision tree.

  ## Basic Usage

  Add the key provider supervisor to your application's supervision tree:

      # In your application.ex file
      defmodule MyApp.Application do
        use Application

        def start(_type, _args) do
          children = [
            # ... your other children
            Lti_1p3.Examples.KeyProviderConfig.child_spec()
          ]

          Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
        end
      end

  ## Custom Configuration

  You can also configure the key provider with custom settings:

      children = [
        {Lti_1p3.KeyProviderSupervisor, [
          key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
          refresh_interval: 600,  # 10 minutes
          cache_ttl: 1800        # 30 minutes
        ]}
      ]

  ## Configuration Options

    * `:key_provider` - The key provider module (default: `Lti_1p3.KeyProviders.MemoryKeyProvider`)
    * `:refresh_interval` - How often to refresh stale keys in seconds (default: 1800 - 30 minutes)
    * `:cache_ttl` - Default cache TTL in seconds (default: 3600 - 1 hour)

  ## Application Configuration

  You can also configure the key provider through your application config:

      # config/config.exs
      config :lti_1p3,
        key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
        key_provider_cache_ttl: 3600,
        key_provider_refresh_interval: 1800
  """

  @doc """
  Returns a child spec for the key provider with default production-ready settings.
  """
  def child_spec(opts \\ []) do
    default_opts = [
      key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
      # 30 minutes
      refresh_interval: 1800,
      # 1 hour
      cache_ttl: 3600
    ]

    merged_opts = Keyword.merge(default_opts, opts)
    {Lti_1p3.KeyProviderSupervisor, merged_opts}
  end

  @doc """
  Returns a child spec optimized for development with faster refresh times.
  """
  def dev_child_spec(opts \\ []) do
    dev_opts = [
      key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
      # 5 minutes
      refresh_interval: 300,
      # 10 minutes
      cache_ttl: 600
    ]

    merged_opts = Keyword.merge(dev_opts, opts)
    {Lti_1p3.KeyProviderSupervisor, merged_opts}
  end

  @doc """
  Returns a child spec optimized for testing with very short refresh times.
  """
  def test_child_spec(opts \\ []) do
    test_opts = [
      key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
      # Disable automatic refresh in tests
      refresh_interval: 0,
      # 1 minute
      cache_ttl: 60
    ]

    merged_opts = Keyword.merge(test_opts, opts)
    {Lti_1p3.KeyProviderSupervisor, merged_opts}
  end
end
