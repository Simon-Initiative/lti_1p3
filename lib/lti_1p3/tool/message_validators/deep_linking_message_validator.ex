defmodule Lti_1p3.Tool.MessageValidators.DeepLinkingMessageValidator do
  @moduledoc """
  Validates deep-linking launch claims via typed request validation.
  """

  @behaviour Lti_1p3.Tool.MessageValidator

  alias Lti_1p3.DeepLinking.ClaimKeys
  alias Lti_1p3.Tool.DeepLinking.Errors
  alias Lti_1p3.Tool.DeepLinking.RequestValidator

  @impl true
  def can_validate?(claims) do
    Map.get(claims, ClaimKeys.key(:message_type)) == "LtiDeepLinkingRequest"
  end

  @impl true
  def validate(claims) do
    case RequestValidator.validate_request(claims) do
      {:ok, _request} ->
        :ok

      {:error, error} ->
        {:error, Errors.to_message_validator_error(error)}
    end
  end
end
