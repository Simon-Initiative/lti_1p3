defmodule Lti_1p3.Claims.DeploymentId do
  @moduledoc """
  A struct representing the deployment_id claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#lti-deployment-id-claim
  """
  @enforce_keys [:deployment_id]

  defstruct [
    :deployment_id
  ]

  @type t() :: %__MODULE__{
          deployment_id: String.t()
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/deployment_id"

  @doc """
  Create a new deployment_id claim.
  """
  def deployment_id(deployment_id), do: %__MODULE__{deployment_id: deployment_id}
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.DeploymentId do
  def get_key(_), do: Lti_1p3.Claims.DeploymentId.key()

  def get_value(%Lti_1p3.Claims.DeploymentId{deployment_id: deployment_id}) do
    deployment_id
  end
end
