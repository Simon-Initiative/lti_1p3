defmodule Lti_1p3.Tool.MessageValidators.ResourceMessageValidator do
  @moduledoc false

  @behaviour Lti_1p3.Tool.MessageValidator

  @message_type_claim "https://purl.imsglobal.org/spec/lti/claim/message_type"
  @version_claim "https://purl.imsglobal.org/spec/lti/claim/version"
  @roles_claim "https://purl.imsglobal.org/spec/lti/claim/roles"
  @resource_link_claim "https://purl.imsglobal.org/spec/lti/claim/resource_link"

  @impl true
  def can_validate?(claims) do
    Map.get(claims, @message_type_claim) == "LtiResourceLinkRequest"
  end

  @impl true
  def validate(claims) do
    with :ok <- required_claim(claims, "sub", :invalid_message, "Must have a user (sub)"),
         :ok <- validate_version(claims),
         :ok <- required_claim(claims, @roles_claim, :invalid_message, "Missing Roles Claim"),
         :ok <- validate_resource_link_id(claims) do
      :ok
    end
  end

  defp validate_version(claims) do
    if Map.get(claims, @version_claim) == "1.3.0" do
      :ok
    else
      {:error, error(:invalid_message, "Incorrect version, expected 1.3.0")}
    end
  end

  defp validate_resource_link_id(claims) do
    case get_in(claims, [@resource_link_claim, "id"]) do
      nil -> {:error, error(:invalid_message, "Missing Resource Link Id")}
      _id -> :ok
    end
  end

  defp required_claim(claims, key, reason, msg) do
    case Map.get(claims, key) do
      nil -> {:error, error(reason, msg)}
      _value -> :ok
    end
  end

  defp error(reason, msg) do
    %{reason: reason, msg: msg, details: %{validator: :resource_link_request}, stage: :message}
  end
end
