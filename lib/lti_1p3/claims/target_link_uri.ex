defmodule Lti_1p3.Claims.TargetLinkUri do
  @moduledoc """
  A struct representing the target_link_uri claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#target-link-uri
  """
  @enforce_keys [:target_link_uri]

  defstruct [
    :target_link_uri
  ]

  @type t() :: %__MODULE__{
          target_link_uri: String.t()
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/target_link_uri"

  @doc """
  Create a new target_link_uri claim.
  """
  def target_link_uri(target_link_uri), do: %__MODULE__{target_link_uri: target_link_uri}
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.TargetLinkUri do
  def get_key(_), do: Lti_1p3.Claims.TargetLinkUri.key()

  def get_value(%Lti_1p3.Claims.TargetLinkUri{target_link_uri: target_link_uri}) do
    target_link_uri
  end
end
