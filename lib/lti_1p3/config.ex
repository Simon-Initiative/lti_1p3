defmodule Lti_1p3.Config do
  @moduledoc """
  Methods to parse and modify configurations.
  """
  @type config :: Keyword.t()
  defmodule ConfigError do
    @moduledoc false
    defexception [:message]
  end

  @doc """
  Gets the default configurations lti_1p3
  """
  @spec default_config() :: config()
  def default_config(), do: [
    http_client: HTTPoison,
  ]

  @doc """
  Gets the environment configuration for key :lti_1p3 in app's environment
  """
  @spec env_config(atom()) :: config()
  def env_config(otp_app \\ :lti_1p3), do: Application.fetch_env!(otp_app, :lti_1p3)

  @doc """
  Gets the configuration which is the env merged with default configs
  """
  @spec get_config(atom()) :: config()
  def get_config(otp_app \\ :lti_1p3), do: merge_configs(default_config(), env_config(otp_app))

  # @doc """
  # Gets the key value from the given configuration.
  # If not found, it'll fall back to environment config, and lastly to the
  # default value which is `nil` if not specified.
  # """
  # @spec get_config(config(), atom(), any()) :: any()
  # def get_config(config, key, default \\ nil)

  # @spec get_config(nil, atom(), any()) :: any()
  # def get_config(nil, key, default) do
  #   get_config(get_config(), key, default)
  # end

  # def get_config(config, key, default) do
  #   Keyword.get(config, key, default)
  # end


  @doc """
  Gets the key value from the configuration.
  If not found, it'll fall back to environment config, and lastly to the
  default value which is `nil` if not specified.
  """
  @spec get(config(), atom(), any()) :: any()
  def get(config, key, default \\ nil) do
    case Keyword.get(config, key, :not_found) do
      :not_found -> get_env_config(config, key, default)
      value      -> value
    end
  end

  defp get_env_config(config, key, default, env_key \\ :lti_1p3) do
    config
    |> Keyword.get(:otp_app)
    |> case do
      nil     -> Application.get_all_env(env_key)
      otp_app -> Application.get_env(otp_app, env_key, [])
    end
    |> Keyword.get(key, default)
  end

  @doc """
  Puts a new key value to the configuration.
  """
  @spec put_config(config(), atom(), any()) :: config()
  def put_config(config, key, value) do
    Keyword.put(config, key, value)
  end

  @doc """
  Merges two configurations.
  """
  @spec merge_configs(config(), config()) :: config()
  def merge_configs(l_config, r_config) do
    Keyword.merge(l_config, r_config)
  end

  @doc """
  Retrieves the repo module from the config, or raises an exception.
  """
  @spec repo!() :: atom()
  def repo!(), do: repo!(get_config())

  @spec repo!(config()) :: atom()
  def repo!(config) do
    get(config, :repo) || raise ConfigError, message: "No `:repo` configuration option found."
  end

  @doc """
  Retrieves the http_client module from the config, or raises an exception.
  """
  @spec http_client!() :: atom()
  def http_client!(), do: http_client!(get_config())

  @spec http_client!(config() | nil) :: atom()
  def http_client!(config) do
    get(config, :http_client) || raise ConfigError, message: "No `:http_client` configuration option found."
  end

  @doc """
  Retrieves the user schema module from the config, or raises an exception.
  """
  @spec user!() :: atom()
  def user!(), do: user!(get_config())

  @spec user!(config() | nil) :: atom()
  def user!(config) do
    get(config, :user) || raise ConfigError, message: "No `:user` configuration option found."
  end

end
