defmodule Lti_1p3.DataProvider do
  alias Lti_1p3.Jwk
  alias Lti_1p3.Nonce
  alias Lti_1p3.DataProviderError

  @doc """
  Creates a new jwk.
  ## Examples
      iex> create_jwk(%Jwk{})
      {:ok, %Jwk{}}
      iex> create_jwk(%Jwk{})
      {:error, %Lti_1p3.DataProviderError{}}
  """
  @callback create_jwk(%Jwk{}) :: {:ok, %Jwk{}} | {:error, DataProviderError.t()}

  @doc """
  Gets the active jwk. If there are more than one, this should return the latest.
  ## Examples
      iex> get_active_jwk()
      {:ok, %Jwk{}}
      iex> get_active_jwk()
      {:error, %Lti_1p3.DataProviderError{}}
  """
  @callback get_active_jwk() :: {:ok, %Jwk{}} | {:error, DataProviderError.t()}

  @doc """
  Gets a list of all jwks.
  ## Examples
      iex> get_all_jwks()
      [%Jwk{}]
  """
  @callback get_all_jwks() :: [%Jwk{}]

  @doc """
  Creates a new nonce.
  ## Examples
      iex> create_nonce(%Nonce{})
      {:ok, %Nonce{}}
      iex> create_nonce(%Nonce{})
      {:error, %Lti_1p3.DataProviderError{}}
  """
  @callback create_nonce(%Nonce{}) :: {:ok, %Nonce{}} | {:error, DataProviderError.t()}

  @doc """
  Gets a nonce with the given value and optional domain.
  ## Examples
      iex> get_nonce(value, domain)
      %Nonce{}
      iex> get_nonce(value, domain)
      nil
  """
  @callback get_nonce(String.t(), String.t() | nil) :: %Nonce{} | nil

  @doc """
  Deletes all expired nonces older than the provided ttl_sec. If no ttl_sec is provided,
  the default value should be 86_400 seconds (1 day).
  ## Examples
      iex> delete_expired_nonces(ttl_sec)
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
  ## Examples
      iex> create_registration(%Registration{})
      {:ok, %Registration{}}
      iex> create_registration(%Registration{})
      {:error, %Lti_1p3.DataProviderError{}}
  """
  @callback create_registration(%Registration{}) :: {:ok, %Registration{}} | {:error, DataProviderError.t()}

  @doc """
  Creates a new deployment.
  ## Examples
      iex> create_deployment(%Deployment{})
      {:ok, %Deployment{}}
      iex> create_deployment(%Deployment{})
      {:error, %Lti_1p3.DataProviderError{}}
  """
  @callback create_deployment(%Deployment{}) :: {:ok, %Deployment{}} | {:error, DataProviderError.t()}

  @doc """
  Gets the registration and deployment associated with the given issuer, client_id and deployment_id.
  ## Examples
      iex> get_registration_deployment(issuer, client_id, deployment_id)
      {%Registration{}, %Deployment{}}
      iex> get_rd_by_deployment_id(issuer, client_id, deployment_id)
      {nil, nil}
  """
  @callback get_registration_deployment(String.t(), String.t(), String.t()) :: {%Registration{}, %Deployment{}} | nil

  @doc """
  Gets the jwk associated with the given Registration.
  ## Examples
      iex> get_jwk_by_registration(%Registration{})
      {:ok, %Jwk{}}
      iex> get_jwk_by_registration(%Registration{})
      {:error, %Lti_1p3.DataProviderError{}}
  """
  @callback get_jwk_by_registration(%Registration{}) :: {:ok, %Jwk{}} | {:error, DataProviderError.t()}

  @doc """
  Gets the registration associated with the given issuer and client_id.
  ## Examples
      iex> get_registration_by_issuer_client_id(issuer, client_id)
      %Registration{}
      iex> get_registration_by_issuer_client_id(issuer, client_id)
      nil
  """
  @callback get_registration_by_issuer_client_id(String.t(), String.t()) :: %Registration{} | nil

  @doc """
  Gets the deployment associated with the given registration and deployment_id.
  ## Examples
      iex> get_deployment(%Registration{}, deployment_id)
      %Deployment{}
      iex> get_deployment(%Registration{}, deployment_id)
      nil
  """
  @callback get_deployment(%Registration{}, String.t()) :: %Deployment{} | nil

  @doc """
  Gets the LTI params associated with a user from the cache using the given key.
  ## Examples
      iex> get_lti_params_by_key(key)
       %LtiParams{}
      iex> get_lti_params_by_key(key)
      nil
  """
  @callback get_lti_params_by_key(String.t()) :: %LtiParams{} | nil

  @doc """
  Creates or updates the LTI params for a user, keying off the 'key' parameter.
  ## Examples
      iex> create_or_update_lti_params(%LtiParams{})
      {:ok, %LtiParams{}}
      iex> create_or_update_lti_params(%LtiParams{})
      {:error, %Lti_1p3.DataProviderError{}}
  """
  @callback create_or_update_lti_params(String.t(), %LtiParams{}) :: {:ok, %LtiParams{}} | {:error, DataProviderError.t()}
end

defmodule Lti_1p3.PlatformDataProvider do
  alias Lti_1p3.Platform.PlatformInstance
  alias Lti_1p3.Platform.LoginHint

  @doc """
  Creates a new platform instance.
  ## Examples
      iex> create_platform_instance(%PlatformInstance{})
      {:ok, %PlatformInstance{}}
      iex> create_platform_instance(%PlatformInstance{})
      {:error, %Lti_1p3.DataProviderError{}}
  """
  @callback create_platform_instance(%PlatformInstance{}) :: {:ok, %PlatformInstance{}} | {:error, DataProviderError.t()}

  @doc """
  Gets a platform instance associated with the given client_id.
  ## Examples
      iex> get_platform_instance_by_client_id(client_id)
      %PlatformInstance{}
      iex> get_platform_instance_by_client_id(client_id)
      nil
  """
  @callback get_platform_instance_by_client_id(String.t()) :: %PlatformInstance{} | nil

  @doc """
  Gets a login hint associated with the given value.
  ## Examples
      iex> get_login_hint_by_value(value)
      %LoginHint{}
      iex> get_login_hint_by_value(value)
      nil
  """
  @callback get_login_hint_by_value(String.t()) :: %LoginHint{} | nil

  @doc """
  Creates a new login hint.
  ## Examples
      iex> create_login_hint(%LoginHint{})
      {:ok, %LoginHint{}}
      iex> create_login_hint(%LoginHint{})
      {:error, %Lti_1p3.DataProviderError{}}
  """
  @callback create_login_hint(%LoginHint{}) :: {:ok, %LoginHint{}} | {:error, DataProviderError.t()}

  @doc """
  Deletes all expired login hints older than the provided ttl_sec. If no ttl_sec is provided,
  the default value should be 86_400 seconds (1 day).
  ## Examples
      iex> delete_expired_login_hints(ttl_sec)
  """
  @callback delete_expired_login_hints(integer() | nil) :: any()
end

defmodule Lti_1p3.DataProviderError do
  defstruct [:msg, :reason]

  @type error_reason() :: :unique_constraint_violation
      | :not_found
      | :unknown

  @type t() :: %__MODULE__{
      msg: String.t(),
      reason: error_reason(),
  }
end
