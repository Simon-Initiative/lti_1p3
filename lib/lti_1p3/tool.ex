defmodule Lti_1p3.Tool do
  import Lti_1p3.Config

  @doc """
  Creates a new deployment.
  ## Examples
      iex> create_deployment(deployment)
      {:ok, %Lti_1p3.Tool.Deployment{}}
      iex> create_deployment(deployment)
      {:error, %Lti_1p3.DataProviderError{}}
  """
  def create_deployment(%Lti_1p3.Tool.Deployment{} = deployment), do:
    provider!().create_deployment(deployment)

  @doc """
  Creates a new registration.
  ## Examples
      iex> create_registration(registration)
      {:ok, %Lti_1p3.Tool.Registration{}}
      iex> create_registration(registration)
      {:error, %Lti_1p3.DataProviderError{}}
  """
  def create_registration(%Lti_1p3.Tool.Registration{} = registration), do:
    provider!().create_registration(registration)

  @doc """
  Gets a user's cached lti_params from the given key.
  Returns `nil` if the lti_params do not exist.
  ## Examples
      iex> get_lti_params_by_key("some-key")
      %Lti_1p3.Tool.LtiParams{}
      iex> get_lti_params_by_key("unknown-key")
      nil
  """
  def get_lti_params_by_key(key), do: provider!().get_lti_params_by_key(key)

  @doc """
  Generates a cache key by using the hash of the provided parameters. The more
  parameters provided, the more specific the key can be. For example, to only generate
  a key for details that pertain to a platform, only provide an issuer and client_id. To
  generate a key for a specific platform user's context, provide all parameters.
  ## Examples
      iex> lti_params_key("some-key")
      %Lti_1p3.Tool.LtiParams{}
      iex> lti_params_key("unknown-key")
      nil
  """
  def lti_params_key(issuer, client_id, user_sub \\ "", context_id \\ ""), do:
    Lti_1p3.Utils.generate_cache_key(issuer, client_id, user_sub, context_id)

  @doc """
  Gets the registration with the given issuer and client_id.
  ## Examples
      iex> get_registration_by_issuer_client_id(issuer, client_id)
      %Registration{}
      iex> get_registration_by_issuer_client_id(issuer, client_id)
      nil
  """
  def get_registration_by_issuer_client_id(issuer, client_id), do:
    provider!().get_registration_by_issuer_client_id(issuer, client_id)

  @doc """
  Gets the registration and deployment associated with the given issuer, client_id and deployment_id.
  ## Examples
      iex> get_registration_deployment(issuer, client_id, deployment_id)
      {%Registration{}, %Deployment{}}
      iex> get_registration_deployment(issuer, client_id, deployment_id)
      {nil, nil}
  """
  def get_registration_deployment(issuer, client_id, deployment_id), do:
    provider!().get_registration_deployment(issuer, client_id, deployment_id)

end
