defmodule Lti_1p3.KeyProviderSupervisor do
  @moduledoc """
  Supervisor for the key provider infrastructure.

  This supervisor manages the key provider GenServer and any related processes
  needed for key caching and refresh functionality.

  ## Usage

  Add this supervisor to your application's supervision tree:

      children = [
        # ... other children
        {Lti_1p3.KeyProviderSupervisor, key_provider_opts()}
      ]

      Supervisor.start_link(children, opts)

  ## Configuration

  The supervisor accepts the following options:

    * `:key_provider` - The key provider module to use (default: `Lti_1p3.KeyProviders.MemoryKeyProvider`)
    * `:key_provider_opts` - Options to pass to the key provider (default: `[]`)
    * `:refresh_interval` - Automatic refresh interval in seconds (default: `1800` - 30 minutes)
    * `:cache_ttl` - Default cache TTL in seconds (default: `3600` - 1 hour)

  Example:

      {Lti_1p3.KeyProviderSupervisor, [
        key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
        refresh_interval: 600,  # 10 minutes
        cache_ttl: 1800        # 30 minutes
      ]}
  """

  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(opts) do
    key_provider = Keyword.get(opts, :key_provider, Lti_1p3.KeyProviders.MemoryKeyProvider)
    key_provider_opts = Keyword.get(opts, :key_provider_opts, [])

    # Pass supervisor options to the key provider
    merged_opts =
      Keyword.merge(key_provider_opts,
        refresh_interval: Keyword.get(opts, :refresh_interval, 1800),
        cache_ttl: Keyword.get(opts, :cache_ttl, 3600)
      )

    children = [
      {key_provider, merged_opts}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
