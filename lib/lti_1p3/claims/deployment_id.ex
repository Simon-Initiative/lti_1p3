defmodule Lti_1p3.Claims.DeploymentId do
  @moduledoc """
  A struct representing the resource link claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#resource-link-claim
  """
  @enforce_keys [:id]

  defstruct [
    :id
  ]

  @type t() :: %__MODULE__{
          id: String.t()
        }
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.DeploymentId do
  def get_key(_), do: "https://purl.imsglobal.org/spec/lti/claim/deployment_id"
end
