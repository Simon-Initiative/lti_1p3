defmodule Lti_1p3.Tool.MessageValidators.DeepLinkingMessageValidator do
  @moduledoc """
  Validation scaffold for LTI deep-linking launch requests.
  """

  @behaviour Lti_1p3.Tool.MessageValidator

  @message_type_claim "https://purl.imsglobal.org/spec/lti/claim/message_type"
  @version_claim "https://purl.imsglobal.org/spec/lti/claim/version"
  @roles_claim "https://purl.imsglobal.org/spec/lti/claim/roles"
  @deep_linking_settings_claim "https://purl.imsglobal.org/spec/lti-dl/claim/deep_linking_settings"

  @impl true
  def can_validate?(claims) do
    Map.get(claims, @message_type_claim) == "LtiDeepLinkingRequest"
  end

  @impl true
  def validate(claims) do
    with :ok <- required_claim(claims, "sub", "Must have a user (sub)"),
         :ok <- required_claim(claims, @roles_claim, "Missing Roles Claim"),
         :ok <- validate_version(claims),
         :ok <- validate_deep_linking_settings(claims) do
      :ok
    end
  end

  defp validate_version(claims) do
    if Map.get(claims, @version_claim) == "1.3.0" do
      :ok
    else
      {:error, error(:invalid_deep_linking_request, "Incorrect version, expected 1.3.0")}
    end
  end

  defp validate_deep_linking_settings(claims) do
    case Map.get(claims, @deep_linking_settings_claim) do
      %{} -> :ok
      _ -> {:error, error(:invalid_deep_linking_request, "Missing deep linking settings claim")}
    end
  end

  defp required_claim(claims, key, msg) do
    case Map.get(claims, key) do
      nil -> {:error, error(:invalid_deep_linking_request, msg)}
      _value -> :ok
    end
  end

  defp error(reason, msg) do
    %{reason: reason, msg: msg, details: %{validator: :deep_linking_request}, stage: :message}
  end
end
