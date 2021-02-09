defmodule Lti_1p3.Nonce do
  @enforce_keys [:value]
  defstruct [:id, :value, :domain]

  @type t() :: %__MODULE__{
    id: integer(),
    value: String.t(),
    domain: String.t(),
  }

  def from(attrs) do
    struct(Lti_1p3.Nonce, attrs)
  end

  def to_map(%Lti_1p3.Nonce{} = nonce) do
    nonce
    |> Map.from_struct()
    |> Map.take(Lti_1p3.Nonce.__struct__() |> Map.keys())
  end
end
