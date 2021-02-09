defmodule Lti_1p3.Config do
  @moduledoc """
  Methods for accessing lti_1p3 config
  """
  @type config :: Keyword.t()
  defmodule Lti_1p3.ConfigError do
    @moduledoc false
    defexception [:message]
  end

  alias Lti_1p3.ConfigError

  defp merge_configs(l_config, r_config) do
    Keyword.merge(l_config, r_config)
  end

  @doc """
  Gets the default configurations lti_1p3
  """
  @spec default_config() :: config()
  def default_config(), do: [
    http_client: HTTPoison,
    registration: Lti_1p3.Registration,

    # login_hints only persist for a day, 86400 seconds = 24 hours
    login_hint_ttl_sec: 86_400,

    # nonces only persist for a day, 86400 seconds = 24 hours
    nonce_ttl_sec: 86_400,
  ]

  @doc """
  Gets the environment configuration for key :lti_1p3 in app's environment
  """
  @spec env_config() :: config()
  def env_config(), do: Application.get_all_env(:lti_1p3)

  @doc """
  Gets the key value from the configuration.
  If not found, it'll fall back to the given default value which is `nil` if not specified.
  """
  def get(key, default \\ nil) do
    merge_configs(default_config(), env_config())
    |> Keyword.get(key, default)
  end

  @doc """
  Retrieves the provider module from the config, or raises an exception.
  """
  @spec provider!() :: atom()
  def provider!() do
    get(:provider) || raise ConfigError, message: "No `:provider` configuration option found."
  end

  @doc """
  Retrieves the http_client module from the config, or raises an exception.
  """
  @spec http_client!() :: atom()
  def http_client!() do
    get(:http_client) || raise ConfigError, message: "No `:http_client` configuration option found."
  end

  @doc """
  Retrieves the user schema module from the config, or raises an exception.
  """
  @spec user!() :: atom()
  def user!() do
    get(:user) || raise ConfigError, message: "No `:user` configuration option found."
  end

end
