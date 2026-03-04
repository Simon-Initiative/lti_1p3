defmodule Lti_1p3.Core.Validation.Message do
  @moduledoc """
  LTI message type dispatch and validation.
  """

  alias Lti_1p3.Core.Errors
  alias Lti_1p3.Tool.MessageDispatch

  @message_type_claim "https://purl.imsglobal.org/spec/lti/claim/message_type"

  @spec validate(map()) :: {:ok, String.t()} | {:error, Errors.t()}
  def validate(claims) do
    case Map.get(claims, @message_type_claim) do
      nil ->
        Errors.error(:message, :invalid_message_type, "Missing message type")

      message_type ->
        case MessageDispatch.validate(claims) do
          :ok ->
            {:ok, message_type}

          {:error, %{reason: reason, msg: msg, details: details}} ->
            Errors.error(:message, reason, msg, Map.put(details, :message_type, message_type))

          {:error, reason, msg} ->
            Errors.error(:message, reason, msg, %{message_type: message_type})

          :unsupported ->
            Errors.error(
              :message,
              :invalid_message_type,
              "Invalid or unsupported message type \"#{message_type}\""
            )
        end
    end
  end
end
