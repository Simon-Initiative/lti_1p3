defmodule Lti_1p3.Claims.Version do
  @moduledoc """
  A struct representing the resource link claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#lti-version-claim
  """
  @enforce_keys [:version]

  defstruct [
    :version
  ]

  @type t() :: %__MODULE__{
          version: String.t()
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/version"

  @doc """
  Create a new version claim.
  """
  def version(version), do: %__MODULE__{version: version}
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.Version do
  def get_key(_), do: Lti_1p3.Claims.Version.key()

  def get_value(%Lti_1p3.Claims.Version{version: version}) do
    version
  end
end
