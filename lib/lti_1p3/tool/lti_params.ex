defmodule Lti_1p3.Tool.LtiParams do
  @enforce_keys [:key, :params, :exp]
  defstruct [:id, :key, :params, :exp]

  @type t() :: %__MODULE__{
    id: integer(),
    key: String.t(),
    params: map(),
    exp: DateTime.t()
  }

end
