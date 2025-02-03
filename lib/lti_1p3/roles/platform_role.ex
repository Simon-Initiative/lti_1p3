defmodule Lti_1p3.Roles.PlatformRole do
  @enforce_keys [:uri]
  defstruct [:id, :uri]

  @type t() :: %__MODULE__{
          id: integer(),
          uri: String.t()
        }
end
