defmodule Lti_1p3.Platform.AuthorizationRedirect do
  import Lti_1p3.Config
  import Lti_1p3.Utils

  alias Lti_1p3.Platform.LoginHint
  alias Lti_1p3.Platform.LoginHints

  alias Lti_1p3.Claims.Claim

  alias Lti_1p3.Claims.{
    MessageType,
    Version,
    ResourceLink,
    DeploymentId,
    Context,
    Roles,
    PlatformInstance,
    TargetLinkUri
  }

  @type params() :: %{state: binary(), id_token: binary()}
  @type user() :: %{id: integer()}

  @type claim() ::
          DeploymentId.t()
          | TargetLinkUri.t()
          | ResourceLink.t()
          | Roles.t()
          | Context.t()
          | PlatformInstance.t()

  @doc """
  Validates an authentication response and returns the state and platform lti params in a signed id_token signed if successful.
  """
  @spec authorize_redirect(
          params(),
          user(),
          binary(),
          list(claim())
        ) ::
          {:ok, binary(), binary(), binary()}
          | {:error, %{optional(atom()) => any(), reason: atom(), msg: String.t()}}
  def authorize_redirect(params, current_user, issuer, claims) do
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

          base_claims =
            %{}
            |> nonce()
            |> oidc_standard_claims(user_details)
            |> oidc_additional_claims(user_details)
            |> add_claim(MessageType.message_type(:lti_resource_link_request))
            |> add_claim(Version.version("1.3.0"))

          with {:ok, claims} <-
                 build_claims_map(base_claims, claims,
                   required: [
                     DeploymentId.key(),
                     TargetLinkUri.key(),
                     ResourceLink.key(),
                     Roles.key()
                   ]
                 ),
               {:ok, claims} <-
                 Joken.Config.default_claims(iss: issuer, aud: client_id)
                 |> Joken.generate_claims(claims),
               {:ok, id_token, _claims} <- Joken.encode_and_sign(claims, signer) do
            state = params["state"]
            redirect_uri = params["redirect_uri"]

            {:ok, redirect_uri, state, id_token}
          else
            error ->
              error
          end
        end
    end
  end

  defp nonce(map) do
    Map.merge(map, %{"nonce" => UUID.uuid4()})
  end

  defp oidc_standard_claims(map, user_details) do
    [
      :sub,
      :given_name,
      :family_name,
      :name,
      :email,
      :locale
    ]
    |> Enum.reduce(map, fn key, acc ->
      case Map.get(user_details, key) do
        nil ->
          acc

        value ->
          Map.put(acc, Atom.to_string(key), value)
      end
    end)
  end

  defp oidc_additional_claims(map, user_details) do
    [
      :middle_name,
      :picture,
      :email,
      :email_verified,
      :nickname,
      :preferred_username,
      :website,
      :gender,
      :birthdate,
      :zoneinfo,
      :phone_number,
      :phone_number_verified,
      :address
    ]
    |> Enum.reduce(map, fn key, acc ->
      case Map.get(user_details, key) do
        nil ->
          acc

        value ->
          Map.put(acc, Atom.to_string(key), value)
      end
    end)
  end

  defp add_claim(map, claim) do
    key = claim |> Claim.get_key()
    value = claim |> Claim.get_value() |> scrub_empty_values()

    Map.put(map, key, value)
  end

  defp scrub_empty_values(%{} = map) do
    Enum.reduce(map, %{}, fn {key, value}, acc ->
      if value != nil do
        Map.put(acc, key, value)
      else
        acc
      end
    end)
  end

  defp scrub_empty_values(value), do: value

  defp build_claims_map(initial, claims, required: required) do
    case Enum.reduce(claims, {initial, required}, fn claim, {claims_map, required} ->
           {add_claim(claims_map, claim), List.delete(required, Claim.get_key(claim))}
         end) do
      {claims_map, []} ->
        {:ok, claims_map}

      {_, missing_claims} ->
        {:error,
         %{
           reason: :missing_required_claims,
           msg: "Missing required claims: #{Enum.join(missing_claims, ", ")}",
           missing_claims: missing_claims
         }}
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
