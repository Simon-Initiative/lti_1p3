defmodule Lti_1p3.Tool do
  @moduledoc """
  Public API for tool-side LTI 1.3 flows and configuration resources.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Tool.Launch
  alias Lti_1p3.Tool.LaunchValidation
  alias Lti_1p3.Tool.OidcLogin

  @type error_map :: %{reason: atom(), stage: atom(), msg: String.t(), details: map()}

  @doc """
  Validates the incoming OIDC login request and returns the redirect payload.

  Returns `{:ok, %{state: state, redirect_url: redirect_url}}` on success.
  """
  @spec login_redirect(map(), keyword()) ::
          {:ok, %{state: String.t(), redirect_url: String.t()}} | {:error, error_map()}
  def login_redirect(params, opts \\ []) do
    case OidcLogin.oidc_login_redirect_url(params, opts) do
      {:ok, state, redirect_url} -> {:ok, %{state: state, redirect_url: redirect_url}}
      {:error, error} -> {:error, ensure_error_shape(error, :login)}
    end
  end

  @doc """
  Validates an incoming LTI launch payload and returns a normalized launch struct.
  """
  @spec validate_launch(map(), String.t() | nil, keyword()) ::
          {:ok, Launch.t()} | {:error, error_map()}
  def validate_launch(params, expected_state, opts \\ []) do
    LaunchValidation.validate(params, expected_state, opts)
  end

  @doc """
  Creates a new deployment.
  """
  @spec create_deployment(Lti_1p3.Tool.Deployment.t()) ::
          {:ok, Lti_1p3.Tool.Deployment.t()} | {:error, Lti_1p3.DataProviderError.t()}
  def create_deployment(%Lti_1p3.Tool.Deployment{} = deployment),
    do: provider!().create_deployment(deployment)

  @doc """
  Creates a new registration.
  """
  @spec create_registration(Lti_1p3.Tool.Registration.t()) ::
          {:ok, Lti_1p3.Tool.Registration.t()} | {:error, Lti_1p3.DataProviderError.t()}
  def create_registration(%Lti_1p3.Tool.Registration{} = registration),
    do: provider!().create_registration(registration)

  @doc """
  Gets the registration associated with issuer and client_id.
  """
  @spec get_registration_by_issuer_client_id(String.t(), String.t()) ::
          Lti_1p3.Tool.Registration.t() | nil
  def get_registration_by_issuer_client_id(issuer, client_id),
    do: provider!().get_registration_by_issuer_client_id(issuer, client_id)

  @doc """
  Gets the registration and deployment associated with issuer, client_id, and deployment_id.
  """
  @spec get_registration_deployment(String.t(), String.t(), String.t()) ::
          {Lti_1p3.Tool.Registration.t() | nil, Lti_1p3.Tool.Deployment.t() | nil}
  def get_registration_deployment(issuer, client_id, deployment_id),
    do: provider!().get_registration_deployment(issuer, client_id, deployment_id)

  defp ensure_error_shape(error, stage) do
    error
    |> Map.put_new(:stage, stage)
    |> Map.put_new(:details, %{})
  end
end
