defmodule Lti_1p3.Platform.AuthorizationRedirect do
  @moduledoc """
  Platform-side authorization redirect validation and id_token generation.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Claims.Claim

  alias Lti_1p3.Claims.{
    Context,
    DeploymentId,
    PlatformInstance,
    ResourceLink,
    Roles,
    TargetLinkUri,
    Version
  }

  alias Lti_1p3.Core.Telemetry
  alias Lti_1p3.Core.Validation.Nonce
  alias Lti_1p3.Platform.LoginHint
  alias Lti_1p3.Platform.LoginHints

  @type params() :: %{optional(String.t()) => String.t()}
  @type user() :: %{id: integer()}

  @type claim() ::
          DeploymentId.t()
          | TargetLinkUri.t()
          | ResourceLink.t()
          | Roles.t()
          | Context.t()
          | PlatformInstance.t()

  @spec authorize_redirect(params(), user(), binary(), list(claim()), keyword()) ::
          {:ok, binary(), binary(), binary()} | {:error, map()}
  def authorize_redirect(params, current_user, issuer, claims, opts \\ []) do
    correlation_id = Keyword.get(opts, :correlation_id, UUID.uuid4())

    with {:ok, platform_instance} <- resolve_platform_instance(params, correlation_id),
         {:ok, valid_redirect_uris} <-
           resolve_valid_redirect_uris(platform_instance, correlation_id),
         :ok <- validate_oidc_params(params, correlation_id),
         :ok <- validate_scope(params, correlation_id),
         :ok <- validate_user(params, current_user, correlation_id),
         :ok <- validate_client(params, platform_instance.client_id, correlation_id),
         :ok <- validate_redirect_uri(params, valid_redirect_uris, correlation_id),
         :ok <- validate_nonce(params, correlation_id),
         {:ok, active_jwk} <- resolve_active_jwk(correlation_id),
         {:ok, id_token} <-
           build_id_token_for_redirect(
             params,
             current_user,
             issuer,
             claims,
             platform_instance.client_id,
             active_jwk,
             correlation_id
           ) do
      Telemetry.emit_outcome(:ok, %{
        flow: :platform_authorize_redirect,
        correlation_id: correlation_id
      })

      {:ok, params["redirect_uri"], params["state"], id_token}
    else
      {:error, %{reason: reason, stage: stage}} = result ->
        Telemetry.emit_outcome(:error, %{
          flow: :platform_authorize_redirect,
          correlation_id: correlation_id,
          reason: reason,
          stage: stage
        })

        result
    end
  end

  defp build_id_token(params, current_user, issuer, claims, client_id, active_jwk) do
    custom_header = %{"kid" => active_jwk.kid}
    signer = Joken.Signer.create("RS256", %{"pem" => active_jwk.pem}, custom_header)
    user_details = Map.from_struct(current_user)

    base_claims =
      %{}
      |> oidc_standard_claims(user_details)
      |> oidc_additional_claims(user_details)
      |> add_claim(Version.version("1.3.0"))
      |> add_claim("nonce", params["nonce"])

    with {:ok, claims} <-
           build_claims_map(base_claims, claims,
             required: [
               DeploymentId.key(),
               TargetLinkUri.key(),
               Roles.key()
             ]
           ),
         {:ok, claims} <-
           Joken.Config.default_claims(iss: issuer, aud: client_id)
           |> Joken.generate_claims(claims),
         {:ok, id_token, _claims} <- Joken.encode_and_sign(claims, signer) do
      {:ok, id_token}
    else
      {:error, %{reason: _reason} = error} ->
        {:error, Map.put_new(error, :stage, :token_build)}

      {:error, reason} ->
        error(:token_build, :token_build_failed, "Unable to build id_token", %{reason: reason})
    end
  end

  defp get_platform_instance(params) do
    case provider!().get_platform_instance_by_client_id(params["client_id"]) do
      nil ->
        error(
          :platform_registration,
          :client_not_registered,
          "No platform exists with client id '#{params["client_id"]}'"
        )

      platform_instance ->
        {:ok, platform_instance}
    end
  end

  defp oidc_standard_claims(map, user_details) do
    [:sub, :given_name, :family_name, :name, :email, :locale]
    |> Enum.reduce(map, fn key, acc ->
      case Map.get(user_details, key) do
        nil -> acc
        value -> Map.put(acc, Atom.to_string(key), value)
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
        nil -> acc
        value -> Map.put(acc, Atom.to_string(key), value)
      end
    end)
  end

  defp add_claim(map, claim) do
    key = claim |> Claim.get_key()
    value = claim |> Claim.get_value() |> scrub_empty_values()

    Map.put(map, key, value)
  end

  defp add_claim(map, key, value), do: Map.put(map, key, value)

  defp scrub_empty_values(%{} = map) do
    Enum.reduce(map, %{}, fn {key, value}, acc ->
      if value != nil, do: Map.put(acc, key, value), else: acc
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
        error(
          :claims,
          :missing_required_claims,
          "Missing required claims: #{Enum.join(missing_claims, ", ")}",
          %{missing_claims: missing_claims}
        )
    end
  end

  defp do_validate_oidc_params(params) do
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
        :ok

      missing_params ->
        error(
          :oidc_params,
          :invalid_oidc_params,
          "Invalid OIDC params. The following parameters are missing: #{Enum.join(missing_params, ", ")}",
          %{missing_params: missing_params}
        )
    end
  end

  defp do_validate_scope(params) do
    if params["scope"] == "openid" do
      :ok
    else
      error(
        :scope,
        :invalid_oidc_scope,
        "Invalid OIDC scope: #{params["scope"]}. Scope must be 'openid'"
      )
    end
  end

  defp do_validate_user(params, %{id: user_id}) do
    case LoginHints.get_login_hint_by_value(params["login_hint"]) do
      %LoginHint{session_user_id: ^user_id} ->
        :ok

      _ ->
        error(:user, :invalid_login_hint, "Login hint must be linked with an active user session")
    end
  end

  defp do_validate_client(params, client_id) do
    if params["client_id"] == client_id do
      :ok
    else
      error(:client, :unauthorized_client, "Client not authorized in requested context")
    end
  end

  defp do_validate_redirect_uri(params, valid_redirect_uris) do
    if params["redirect_uri"] in valid_redirect_uris do
      :ok
    else
      error(
        :redirect,
        :unauthorized_redirect_uri,
        "Redirect URI not authorized in requested context"
      )
    end
  end

  defp resolve_platform_instance(params, correlation_id) do
    case get_platform_instance(params) do
      {:ok, platform_instance} ->
        emit_stage_ok(:platform_registration, correlation_id)
        {:ok, platform_instance}

      {:error, error} ->
        emit_stage_error(:platform_registration, error, correlation_id)
    end
  end

  defp resolve_valid_redirect_uris(platform_instance, correlation_id) do
    emit_stage_ok(:redirect, correlation_id)
    {:ok, String.split(platform_instance.redirect_uris, ",", trim: true)}
  end

  defp validate_oidc_params(params, correlation_id) do
    case do_validate_oidc_params(params) do
      :ok ->
        emit_stage_ok(:oidc_params, correlation_id)
        :ok

      {:error, error} ->
        emit_stage_error(:oidc_params, error, correlation_id)
    end
  end

  defp validate_scope(params, correlation_id) do
    case do_validate_scope(params) do
      :ok ->
        emit_stage_ok(:scope, correlation_id)
        :ok

      {:error, error} ->
        emit_stage_error(:scope, error, correlation_id)
    end
  end

  defp validate_user(params, current_user, correlation_id) do
    case do_validate_user(params, current_user) do
      :ok ->
        emit_stage_ok(:user, correlation_id)
        :ok

      {:error, error} ->
        emit_stage_error(:user, error, correlation_id)
    end
  end

  defp validate_client(params, client_id, correlation_id) do
    case do_validate_client(params, client_id) do
      :ok ->
        emit_stage_ok(:client, correlation_id)
        :ok

      {:error, error} ->
        emit_stage_error(:client, error, correlation_id)
    end
  end

  defp validate_redirect_uri(params, valid_redirect_uris, correlation_id) do
    case do_validate_redirect_uri(params, valid_redirect_uris) do
      :ok ->
        emit_stage_ok(:redirect, correlation_id)
        :ok

      {:error, error} ->
        emit_stage_error(:redirect, error, correlation_id)
    end
  end

  defp validate_nonce(params, correlation_id) do
    case Nonce.validate(%{"nonce" => params["nonce"]}, "authorize_redirect") do
      :ok ->
        emit_stage_ok(:nonce, correlation_id)
        :ok

      {:error, error} ->
        emit_stage_error(:nonce, error, correlation_id)
    end
  end

  defp resolve_active_jwk(correlation_id) do
    case provider!().get_active_jwk() do
      {:ok, active_jwk} ->
        emit_stage_ok(:signing, correlation_id)
        {:ok, active_jwk}

      {:error, reason} when is_map(reason) ->
        emit_stage_error(:signing, reason, correlation_id)
    end
  end

  defp build_id_token_for_redirect(
         params,
         current_user,
         issuer,
         claims,
         client_id,
         active_jwk,
         correlation_id
       ) do
    case build_id_token(params, current_user, issuer, claims, client_id, active_jwk) do
      {:ok, id_token} ->
        emit_stage_ok(:token_build, correlation_id)
        {:ok, id_token}

      {:error, error} ->
        emit_stage_error(:token_build, error, correlation_id)
    end
  end

  defp emit_stage_ok(stage, correlation_id) do
    Telemetry.emit_stage(stage, :ok, %{
      flow: :platform_authorize_redirect,
      correlation_id: correlation_id
    })
  end

  defp emit_stage_error(stage, error, correlation_id) do
    error = ensure_error_shape(error, stage)

    Telemetry.emit_stage(stage, :error, %{
      flow: :platform_authorize_redirect,
      correlation_id: correlation_id,
      reason: error.reason,
      stage: error.stage
    })

    {:error, error}
  end

  defp ensure_error_shape(error, stage) do
    error
    |> Map.put_new(:stage, stage)
    |> Map.put_new(:details, %{})
  end

  defp error(stage, reason, msg, details \\ %{}) do
    {:error, %{reason: reason, stage: stage, msg: msg, details: details}}
  end
end
