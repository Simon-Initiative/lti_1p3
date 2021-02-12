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

end
