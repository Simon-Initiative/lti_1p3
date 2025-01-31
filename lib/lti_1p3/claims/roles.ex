defmodule Lti_1p3.Claims.Roles do
  @moduledoc """
  A struct representing the resource link claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#resource-link-claim
  """
  alias Lti_1p3.Tool.{ContextRole, PlatformRole}

  @enforce_keys [:roles]

  defstruct [
    :roles
  ]

  @type t() :: %__MODULE__{
          roles: [ContextRole.t() | PlatformRole.t()]
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/roles"

  @doc """
  Create a new roles claim.
  """
  def roles(roles), do: %__MODULE__{roles: roles}
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.Roles do
  def get_key(_), do: Lti_1p3.Claims.Roles.key()

  def get_value(%Lti_1p3.Claims.Roles{roles: roles}) do
    roles
  end
end
