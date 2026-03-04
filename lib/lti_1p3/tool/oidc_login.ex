defmodule Lti_1p3.Tool.OidcLogin do
  @moduledoc """
  Tool-side OIDC login request validation and redirect URL construction.
  """

  import Lti_1p3.Config

  @type error_map :: %{reason: atom(), stage: atom(), msg: String.t(), details: map()}

  @spec oidc_login_redirect_url(map(), keyword()) ::
          {:ok, String.t(), String.t()} | {:error, error_map()}
  def oidc_login_redirect_url(params, _opts \\ []) do
    with {:ok, _issuer, login_hint, registration} <- validate_oidc_login(params) do
      state = UUID.uuid4()

      query_params = %{
        "scope" => "openid",
        "response_type" => "id_token",
        "response_mode" => "form_post",
        "prompt" => "none",
        "client_id" => params["client_id"],
        "redirect_uri" => params["target_link_uri"],
        "state" => state,
        "nonce" => UUID.uuid4(),
        "login_hint" => login_hint
      }

      query_params =
        case params["lti_message_hint"] do
          nil -> query_params
          lti_message_hint -> Map.put_new(query_params, "lti_message_hint", lti_message_hint)
        end

      redirect_url = registration.auth_login_url <> "?" <> URI.encode_query(query_params)

      {:ok, state, redirect_url}
    end
  end

  defp validate_oidc_login(params) do
    with {:ok, issuer} <- validate_issuer(params),
         {:ok, login_hint} <- validate_login_hint(params),
         {:ok, registration} <- validate_registration(params) do
      {:ok, issuer, login_hint, registration}
    end
  end

  defp validate_issuer(params) do
    case params["iss"] do
      nil -> error(:missing_issuer, "Request does not have an issuer (iss)")
      issuer -> {:ok, issuer}
    end
  end

  defp validate_login_hint(params) do
    case params["login_hint"] do
      nil -> error(:missing_login_hint, "Request does not have a login hint (login_hint)")
      login_hint -> {:ok, login_hint}
    end
  end

  defp validate_registration(params) do
    issuer = params["iss"]
    client_id = params["client_id"]
    lti_deployment_id = params["lti_deployment_id"]

    case provider!().get_registration_by_issuer_client_id(issuer, client_id) do
      nil ->
        error(
          :invalid_registration,
          "Registration with issuer \"#{issuer}\" and client id \"#{client_id}\" not found",
          %{issuer: issuer, client_id: client_id, lti_deployment_id: lti_deployment_id}
        )

      registration ->
        {:ok, registration}
    end
  end

  defp error(reason, msg, details \\ %{}) do
    {:error, %{reason: reason, stage: :login, msg: msg, details: details}}
  end
end
