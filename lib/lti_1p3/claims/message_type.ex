defmodule Lti_1p3.Claims.MessageType do
  @moduledoc """
  A struct representing the message type claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#message-type-claim
  """
  @enforce_keys [:type]

  defstruct [
    :type
  ]

  @type t() :: %__MODULE__{
          type: String.t()
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/message_type"

  @doc """
  Create a new message type claim.
  """
  def message_type(:lti_resource_link_request), do: %__MODULE__{type: "LtiResourceLinkRequest"}
  def message_type(:lti_deep_linking_request), do: %__MODULE__{type: "LtiDeepLinkingRequest"}
  def message_type(:lti_deep_linking_response), do: %__MODULE__{type: "LtiDeepLinkingResponse"}
  def message_type(_), do: throw("Invalid message type")
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.MessageType do
  def get_key(_), do: Lti_1p3.Claims.MessageType.key()

  def get_value(%Lti_1p3.Claims.MessageType{type: type}) do
    type
  end
end
