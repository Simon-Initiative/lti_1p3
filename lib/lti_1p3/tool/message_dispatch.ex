defmodule Lti_1p3.Tool.MessageDispatch do
  @moduledoc """
  Dispatches LTI launch message validation by message type.
  """

  alias Lti_1p3.Tool.MessageValidators.DeepLinkingMessageValidator
  alias Lti_1p3.Tool.MessageValidators.ResourceMessageValidator

  @validators [
    ResourceMessageValidator,
    DeepLinkingMessageValidator
  ]

  @spec validate(map()) :: :ok | :unsupported | {:error, map()} | {:error, atom(), String.t()}
  def validate(claims) do
    case Enum.find(@validators, & &1.can_validate?(claims)) do
      nil -> :unsupported
      validator -> validator.validate(claims)
    end
  end
end
