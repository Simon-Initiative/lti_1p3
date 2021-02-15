defmodule Lti_1p3.DataProvider do
  alias Lti_1p3.Jwk
  alias Lti_1p3.Nonce

  @callback create_jwk(%Jwk{}) :: {:ok, %Jwk{}} | {:error, Lti_1p3.DataProviderError.t()}
  @callback get_active_jwk() :: {:ok, %Jwk{}} | {:error, Lti_1p3.DataProviderError.t()}
  @callback get_all_jwks() :: [%Jwk{}]
  @callback create_nonce(%Nonce{}) :: {:ok, %Nonce{}} | {:error, Lti_1p3.DataProviderError.t()}
  @callback get_nonce(String.t(), String.t() | nil) :: %Nonce{} | nil
  @callback delete_expired_nonces(integer() | nil) :: any()
end

defmodule Lti_1p3.ToolDataProvider do
  alias Lti_1p3.Jwk
  alias Lti_1p3.Tool.Registration
  alias Lti_1p3.Tool.Deployment
  alias Lti_1p3.Tool.LtiParams

  @callback create_registration(%Registration{}) :: {:ok, %Registration{}} | {:error, Lti_1p3.DataProviderError.t()}
  @callback create_deployment(%Deployment{}) :: {:ok, %Deployment{}} | {:error, Lti_1p3.DataProviderError.t()}
  @callback get_rd_by_deployment_id(String.t()) :: {%Registration{}, %Deployment{}} | nil
  @callback get_jwk_by_registration(%Registration{}) :: {:ok, %Jwk{}} | {:error, Lti_1p3.DataProviderError.t()}
  @callback get_registration_by_issuer_client_id(String.t(), String.t()) :: %Registration{} | nil
  @callback get_deployment(%Registration{}, String.t()) :: %Deployment{} | nil
  @callback get_lti_params_by_sub(String.t()) :: %LtiParams{} | nil
  @callback create_or_update_lti_params(%LtiParams{}) :: {:ok, %LtiParams{}} | {:error, Lti_1p3.DataProviderError.t()}
end

defmodule Lti_1p3.PlatformDataProvider do
  alias Lti_1p3.Platform.PlatformInstance
  alias Lti_1p3.Platform.LoginHint

  @callback create_platform_instance(%PlatformInstance{}) :: {:ok, %PlatformInstance{}} | {:error, Lti_1p3.DataProviderError.t()}
  @callback get_platform_instance_by_client_id(String.t()) :: %PlatformInstance{} | nil
  @callback get_login_hint_by_value(String.t()) :: %LoginHint{} | nil
  @callback create_login_hint(%LoginHint{}) :: {:ok, %LoginHint{}} | {:error, Lti_1p3.DataProviderError.t()}
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
