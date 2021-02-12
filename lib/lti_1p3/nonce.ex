defmodule Lti_1p3.Nonce do
  @enforce_keys [:value]
  defstruct [:id, :value, :domain]

  @type t() :: %__MODULE__{
    id: integer(),
    value: String.t(),
    domain: String.t(),
  }

end
