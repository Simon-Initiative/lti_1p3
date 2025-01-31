defmodule Lti_1p3.Claims.RoleScopeMentor do
  @moduledoc """
  A struct representing the resource link claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#role-scope-mentor-claims
  """
  @enforce_keys [:user_ids]

  defstruct [
    :user_ids
  ]

  @type t() :: %__MODULE__{
          user_ids: list(String.t())
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/role_scope_mentor"

  @doc """
  Create a new role_scope_mentor claim.
  """
  def role_scope_mentor(user_ids), do: %__MODULE__{user_ids: user_ids}
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.RoleScopeMentor do
  def get_key(_), do: Lti_1p3.Claims.RoleScopeMentor.key()

  def get_value(%Lti_1p3.Claims.RoleScopeMentor{user_ids: user_ids}) do
    user_ids
  end
end
