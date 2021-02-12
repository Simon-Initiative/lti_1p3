defmodule Lti_1p3.Tool.Deployment do
  @enforce_keys [:deployment_id, :registration_id]
  defstruct [:id, :deployment_id, :registration_id]

  @type t() :: %__MODULE__{
    id: integer(),
    deployment_id: String.t(),
    registration_id: integer()
  }

end
