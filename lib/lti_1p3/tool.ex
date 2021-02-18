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
      iex> registration(registration)
      {:ok, %Lti_1p3.Tool.Registration{}}
      iex> registration(registration)
      {:error, %Lti_1p3.DataProviderError{}}
  """
  def create_registration(%Lti_1p3.Tool.Registration{} = registration), do:
    provider!().create_registration(registration)

  @doc """
  Gets a user's cached lti_params from the given sub.
  Returns `nil` if the lti_params do not exist.
  ## Examples
      iex> Lti_1p3.get_lti_params_by_sub("some-sub")
      %Lti_1p3.Tool.LtiParams{}
      iex> Lti_1p3.get_lti_params_by_sub("unknown-sub")
      nil
  """
  def get_lti_params_by_sub(sub), do: provider!().get_lti_params_by_sub(sub)

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
