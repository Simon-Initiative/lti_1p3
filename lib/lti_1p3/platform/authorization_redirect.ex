defmodule Lti_1p3.Platform.AuthorizationRedirect do
  import Lti_1p3.Config
  import Lti_1p3.Utils

  alias Lti_1p3.Platform.LoginHint
  alias Lti_1p3.Platform.LoginHints
  alias Lti_1p3.Claims.{ResourceLink}
  alias Lti_1p3.Tool.{ContextRole, PlatformRole}

  @type params() :: %{state: binary(), id_token: binary()}
  @type user() :: %{id: integer()}

  @doc """
  Validates an authentication response and returns the state and platform lti params in a signed id_token signed if successful.
  """
  @spec authorize_redirect(
          params(),
          user(),
          binary(),
          binary(),
          ResourceLink.t(),
          list(ContextRole.t() | PlatformRole.t())
        ) ::
          {:ok, binary(), binary(), binary()}
          | {:error, %{optional(atom()) => any(), reason: atom(), msg: String.t()}}
  def authorize_redirect(params, current_user, issuer, deployment_id, resource_link, roles) do
    case provider!().get_platform_instance_by_client_id(params["client_id"]) do
      nil ->
        {:error,
         %{
           reason: :client_not_registered,
           msg: "No platform exists with client id '#{params["client_id"]}'"
         }}

      platform_instance ->
        client_id = platform_instance.client_id
        valid_redirect_uris = platform_instance.redirect_uris |> String.split(",")

        # perform authentication response validation per LTI 1.3 specification
        # https://www.imsglobal.org/spec/security/v1p0/#step-3-authentication-response
        with {:ok} <- validate_oidc_params(params),
             {:ok} <- validate_oidc_scope(params),
             {:ok} <- validate_current_user(params, current_user),
             {:ok} <- validate_client_id(params, client_id),
             {:ok} <- validate_redirect_uri(params, valid_redirect_uris),
             {:ok} <- validate_nonce(params, "authorize_redirect"),
             {:ok, active_jwk} <- provider!().get_active_jwk() do
          custom_header = %{"kid" => active_jwk.kid}
          signer = Joken.Signer.create("RS256", %{"pem" => active_jwk.pem}, custom_header)
          user_details = Map.from_struct(current_user)

          {:ok, claims} =
            Joken.Config.default_claims(iss: issuer, aud: client_id)
            |> Joken.generate_claims(%{
              "nonce" => UUID.uuid4(),
              "sub" => user_details[:sub],
              "name" => user_details[:name],
              "given_name" => user_details[:given_name],
              "family_name" => user_details[:family_name],
              "middle_name" => user_details[:middle_name],
              "picture" => user_details[:picture],
              "email" => user_details[:email],
              "email_verified," => user_details[:email_verified],
              "locale" => user_details[:locale],
              "nickname" => user_details[:nickname],
              "preferred_username" => user_details[:preferred_username],
              "website" => user_details[:website],
              "gender" => user_details[:gender],
              "birthdate" => user_details[:birthdate],
              "zoneinfo" => user_details[:zoneinfo],
              "phone_number" => user_details[:phone_number],
              "phone_number_verified" => user_details[:phone_number_verified],
              "address" => user_details[:address],
              "https://purl.imsglobal.org/spec/lti/claim/message_type" =>
                "LtiResourceLinkRequest",
              "https://purl.imsglobal.org/spec/lti/claim/version" => "1.3.0",
              "https://purl.imsglobal.org/spec/lti/claim/deployment_id" => deployment_id,
              "https://purl.imsglobal.org/spec/lti/claim/target_link_uri" =>
                platform_instance.target_link_uri,
              "https://purl.imsglobal.org/spec/lti/claim/resource_link" => resource_link,
              "https://purl.imsglobal.org/spec/lti/claim/roles" => Enum.map(roles, & &1.uri)
            })

          {:ok, id_token, _claims} = Joken.encode_and_sign(claims, signer)

          state = params["state"]
          redirect_uri = params["redirect_uri"]

          {:ok, redirect_uri, state, id_token}
        end
    end
  end

  defp validate_oidc_params(params) do
    required_param_keys = [
      "client_id",
      "login_hint",
      "nonce",
      "prompt",
      "redirect_uri",
      "response_mode",
      "response_type",
      "scope"
    ]

    case Enum.filter(required_param_keys, fn required_key ->
           !Map.has_key?(params, required_key)
         end) do
      [] ->
        {:ok}

      missing_params ->
        {:error,
         %{
           reason: :invalid_oidc_params,
           msg:
             "Invalid OIDC params. The following parameters are missing: #{Enum.join(missing_params, ", ")}",
           missing_params: missing_params
         }}
    end
  end

  defp validate_oidc_scope(params) do
    if params["scope"] == "openid" do
      {:ok}
    else
      {:error,
       %{
         reason: :invalid_oidc_scope,
         msg: "Invalid OIDC scope: #{params["scope"]}. Scope must be 'openid'"
       }}
    end
  end

  defp validate_current_user(params, %{id: user_id}) do
    case LoginHints.get_login_hint_by_value(params["login_hint"]) do
      %LoginHint{session_user_id: ^user_id} ->
        {:ok}

      _ ->
        {:error,
         %{
           reason: :invalid_login_hint,
           msg: "Login hint must be linked with an active user session"
         }}
    end
  end

  defp validate_client_id(params, client_id) do
    if params["client_id"] == client_id do
      {:ok}
    else
      {:error, %{reason: :unauthorized_client, msg: "Client not authorized in requested context"}}
    end
  end

  defp validate_redirect_uri(params, valid_redirect_uris) do
    if params["redirect_uri"] in valid_redirect_uris do
      {:ok}
    else
      {:error,
       %{
         reason: :unauthorized_redirect_uri,
         msg: "Redirect URI not authorized in requested context"
       }}
    end
  end
end
