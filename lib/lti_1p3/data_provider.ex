defmodule Lti_1p3.DataProvider do
  alias Lti_1p3.Jwk
  alias Lti_1p3.Nonce
  alias Lti_1p3.DataProviderError

  @doc """
  Creates a new jwk.
  """
  @callback create_jwk(%Jwk{}) :: {:ok, %Jwk{}} | {:error, DataProviderError.t()}

  @doc """
  Gets the active jwk. If there are more than one, this should return the latest.
  """
  @callback get_active_jwk() :: {:ok, %Jwk{}} | {:error, DataProviderError.t()}

  @doc """
  Gets a list of all jwks.
  """
  @callback get_all_jwks() :: [%Jwk{}]

  @doc """
  Creates a new nonce.
  """
  @callback create_nonce(%Nonce{}) :: {:ok, %Nonce{}} | {:error, DataProviderError.t()}

  @doc """
  Gets a nonce with the given value and optional domain.
  """
  @callback get_nonce(String.t(), String.t() | nil) :: %Nonce{} | nil

  @doc """
  Deletes all expired nonces older than the provided ttl_sec. If no ttl_sec is provided,
  the default value should be 86_400 seconds (1 day).
  """
  @callback delete_expired_nonces(integer() | nil) :: any()
end

defmodule Lti_1p3.ToolDataProvider do
  alias Lti_1p3.Jwk
  alias Lti_1p3.Tool.Registration
  alias Lti_1p3.Tool.Deployment
  alias Lti_1p3.Tool.LtiParams

  @doc """
  Creates a new registration.
  """
  @callback create_registration(%Registration{}) :: {:ok, %Registration{}} | {:error, DataProviderError.t()}

  @doc """
  Creates a new deployment.
  """
  @callback create_deployment(%Deployment{}) :: {:ok, %Deployment{}} | {:error, DataProviderError.t()}

  @doc """
  Gets the registration and deployment associated with the given deployment_id.
  """
  @callback get_rd_by_deployment_id(String.t()) :: {%Registration{}, %Deployment{}} | nil

  @doc """
  Gets the jwk associated with the given Registration.
  """
  @callback get_jwk_by_registration(%Registration{}) :: {:ok, %Jwk{}} | {:error, DataProviderError.t()}

  @doc """
  Gets the registration associated with the given issuer and client_id.
  """
  @callback get_registration_by_issuer_client_id(String.t(), String.t()) :: %Registration{} | nil

  @doc """
  Gets the deployment associated with the given registration and deployment_id.
  """
  @callback get_deployment(%Registration{}, String.t()) :: %Deployment{} | nil

  @doc """
  Gets the LTI params associated with a user from the cache using the given sub.
  """
  @callback get_lti_params_by_sub(String.t()) :: %LtiParams{} | nil

  @doc """
  Creates or updates the LTI params for a user, keying off the 'sub' parameter.
  """
  @callback create_or_update_lti_params(%LtiParams{}) :: {:ok, %LtiParams{}} | {:error, DataProviderError.t()}
end

defmodule Lti_1p3.PlatformDataProvider do
  alias Lti_1p3.Platform.PlatformInstance
  alias Lti_1p3.Platform.LoginHint

  @doc """
  Creates a new platform instance.
  """
  @callback create_platform_instance(%PlatformInstance{}) :: {:ok, %PlatformInstance{}} | {:error, DataProviderError.t()}

  @doc """
  Gets a platform instance associated with the given client_id.
  """
  @callback get_platform_instance_by_client_id(String.t()) :: %PlatformInstance{} | nil

  @doc """
  Gets a login hint associated with the given value.
  """
  @callback get_login_hint_by_value(String.t()) :: %LoginHint{} | nil

  @doc """
  Creates a new login hint.
  """
  @callback create_login_hint(%LoginHint{}) :: {:ok, %LoginHint{}} | {:error, DataProviderError.t()}

  @doc """
  Deletes all expired login hints older than the provided ttl_sec. If no ttl_sec is provided,
  the default value should be 86_400 seconds (1 day).
  """
  @callback delete_expired_login_hints(integer() | nil) :: any()
end

defmodule Lti_1p3.DataProviderError do
  @moduledoc false
  defstruct [:msg, :reason]

  @type error_reason() :: :unique_constraint_violation
      | :not_found
      | :unknown

  @type t() :: %__MODULE__{
      msg: String.t(),
      reason: error_reason(),
  }
end
