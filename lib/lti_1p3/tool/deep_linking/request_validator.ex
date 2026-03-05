defmodule Lti_1p3.Tool.DeepLinking.RequestValidator do
  @moduledoc """
  Validates and parses `LtiDeepLinkingRequest` launch claims into typed structures.
  """

  alias Lti_1p3.DeepLinking.ClaimKeys
  alias Lti_1p3.Tool.DeepLinking.Errors
  alias Lti_1p3.Tool.DeepLinking.Request
  alias Lti_1p3.Tool.DeepLinking.Settings

  @required_string_claims ["iss", "sub", "nonce"]

  @spec validate_request(map()) :: {:ok, Request.t()} | {:error, Errors.t()}
  def validate_request(%{} = claims) do
    with :ok <- validate_required_string_claims(claims),
         :ok <- validate_message_type(claims),
         :ok <- validate_version(claims),
         {:ok, roles} <- validate_roles(claims),
         {:ok, settings} <- validate_settings(claims) do
      {:ok,
       %Request{
         issuer: claims["iss"],
         audience: claims["aud"],
         subject: claims["sub"],
         nonce: claims["nonce"],
         version: claims[ClaimKeys.key(:version)],
         message_type: claims[ClaimKeys.key(:message_type)],
         roles: roles,
         settings: settings,
         claims: claims
       }}
    end
  end

  def validate_request(_claims) do
    Errors.error(:request, :invalid_deep_linking_request, "Launch claims must be a map")
  end

  defp validate_required_string_claims(claims) do
    case Enum.find(@required_string_claims, &(not valid_string?(Map.get(claims, &1)))) do
      nil ->
        :ok

      missing_claim ->
        Errors.error(
          :request,
          :invalid_deep_linking_request,
          "Missing or invalid #{missing_claim} claim",
          %{claim: missing_claim}
        )
    end
  end

  defp validate_message_type(claims) do
    if Map.get(claims, ClaimKeys.key(:message_type)) == "LtiDeepLinkingRequest" do
      :ok
    else
      Errors.error(
        :request,
        :invalid_deep_linking_request,
        "Message type must be LtiDeepLinkingRequest"
      )
    end
  end

  defp validate_version(claims) do
    if Map.get(claims, ClaimKeys.key(:version)) == "1.3.0" do
      :ok
    else
      Errors.error(:request, :invalid_deep_linking_request, "Incorrect version, expected 1.3.0")
    end
  end

  defp validate_roles(claims) do
    case Map.get(claims, ClaimKeys.key(:roles)) do
      roles when is_list(roles) and roles != [] ->
        roles
        |> Enum.filter(&is_binary/1)
        |> case do
          [] -> Errors.error(:request, :invalid_deep_linking_request, "Missing Roles Claim")
          valid_roles -> {:ok, valid_roles}
        end

      _ ->
        Errors.error(:request, :invalid_deep_linking_request, "Missing Roles Claim")
    end
  end

  defp validate_settings(claims) do
    claims
    |> Map.get(ClaimKeys.key(:deep_linking_settings))
    |> case do
      %{} = settings_claim ->
        Settings.parse(settings_claim)

      _ ->
        Errors.error(
          :request,
          :invalid_deep_linking_request,
          "Missing deep linking settings claim"
        )
    end
  end

  defp valid_string?(value), do: is_binary(value) and value != ""
end
