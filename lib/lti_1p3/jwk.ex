defmodule Lti_1p3.Jwk do
  @enforce_keys [:pem, :typ, :alg, :kid]
  defstruct [:id, :pem, :typ, :alg, :kid, :active]

  @type t() :: %__MODULE__{
    id: integer(),
    pem: String.t(),
    typ: String.t(),
    alg: String.t(),
    kid: String.t(),
    active: boolean()
  }

  def from(attrs) do
    struct(Lti_1p3.Jwk, attrs)
  end

  def to_map(%Lti_1p3.Jwk{} = jwk) do
    jwk
    |> Map.from_struct()
    |> Map.take(Lti_1p3.Jwk.__struct__() |> Map.keys())
  end
end
