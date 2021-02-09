defmodule Lti_1p3.Tool.LtiParams do
  @enforce_keys [:key, :data, :exp]
  defstruct [:id, :key, :data, :exp]

  @type t() :: %__MODULE__{
    id: integer(),
    key: String.t(),
    data: map(),
    exp: DateTime.t()
  }

  def from(attrs) do
    struct(Lti_1p3.Tool.LtiParams, attrs)
  end

  def to_map(%Lti_1p3.Tool.LtiParams{} = lti_params) do
    lti_params
    |> Map.from_struct()
    |> Map.take(Lti_1p3.Tool.LtiParams.__struct__() |> Map.keys())
  end
end
