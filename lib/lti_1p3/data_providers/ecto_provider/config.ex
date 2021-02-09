defmodule Lti_1p3.DataProviders.EctoProvider.Config do
  @moduledoc """
  Methods for accessing ecto provider config
  """
  @type config :: Keyword.t()
  defmodule Lti_1p3.DataProviders.EctoProvider.ConfigError do
    @moduledoc false
    defexception [:message]
  end

  alias Lti_1p3.DataProviders.EctoProvider.ConfigError

  defp merge_configs(l_config, r_config) do
    Keyword.merge(l_config, r_config)
  end

  @doc """
  Gets the default configurations lti_1p3
  """
  @spec default_config() :: config()
  def default_config(), do: [
    schemas: [
      registration: :"Elixir.Lti_1p3.DataProviders.EctoProvider.Registration",
      platform_instance: :"Elixir.Lti_1p3.DataProviders.EctoProvider.PlatformInstance",
      lti_params: :"Elixir.Lti_1p3.DataProviders.EctoProvider.LtiParams",
      login_hint: :"Elixir.Lti_1p3.DataProviders.EctoProvider.LoginHint",
      nonce: :"Elixir.Lti_1p3.DataProviders.EctoProvider.Nonce",
      jwk: :"Elixir.Lti_1p3.DataProviders.EctoProvider.Jwk",
      deployment: :"Elixir.Lti_1p3.DataProviders.EctoProvider.Deployment",
      platform_role: :"Elixir.Lti_1p3.DataProviders.EctoProvider.PlatformRole",
      context_role: :"Elixir.Lti_1p3.DataProviders.EctoProvider.ContextRole",
    ]
  ]

  @doc """
  Gets the environment configuration for key :lti_1p3 in app's environment
  """
  @spec env_config() :: config()
  def env_config(), do: Application.get_env(:lti_1p3, :ecto_provider) || []

  @doc """
  Gets the key value from the configuration.
  If not found, it'll fall back to the given default value which is `nil` if not specified.
  """
  def get(key, default \\ nil) do
    merge_configs(default_config(), env_config())
    |> Keyword.get(key, default)
  end

  @doc """
  Retrieves the repo module from the config, or raises an exception.
  """
  @spec repo!() :: atom()
  def repo!() do
    get(:repo) || raise ConfigError, message: "No `:repo` configuration option found."
  end

  @doc """
  Retrieves the given schema module from the config
  """
  @spec schema(atom()) :: atom()
  def schema(name) do
    get(:schemas)
    |> Keyword.get(name) || raise ConfigError, message: "Invalid schema configuration for `:#{name}`."
  end

end
