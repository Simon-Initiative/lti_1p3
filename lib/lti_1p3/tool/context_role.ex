defmodule Lti_1p3.Tool.ContextRole do
  @enforce_keys [:uri]
  defstruct [:id, :uri]

  @type t() :: %__MODULE__{
    id: integer(),
    uri: String.t(),
  }
end
