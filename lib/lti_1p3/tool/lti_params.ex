defmodule Lti_1p3.Tool.LtiParams do
  @enforce_keys [:sub, :params, :exp]
  defstruct [:id, :sub, :params, :exp]

  @type t() :: %__MODULE__{
    id: integer(),
    sub: String.t(),
    params: map(),
    exp: DateTime.t()
  }

end
