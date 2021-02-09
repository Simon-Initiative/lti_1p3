defmodule Lti_1p3.Tool.Deployment do
  @enforce_keys [:deployment_id, :registration_id]
  defstruct [:id, :deployment_id, :registration_id]

  @type t() :: %__MODULE__{
    id: integer(),
    deployment_id: String.t(),
    registration_id: integer()
  }

  def from(attrs) do
    struct(Lti_1p3.Tool.Deployment, attrs)
  end

  def to_map(%Lti_1p3.Tool.Deployment{} = deployment) do
    deployment
    |> Map.from_struct()
    |> Map.take(Lti_1p3.Tool.Deployment.__struct__() |> Map.keys())
  end
end
