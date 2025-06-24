defmodule Lti_1p3.Roles.PlatformRole do
  @enforce_keys [:uri]
  defstruct [:id, :uri]

  @type t() :: %__MODULE__{
          id: integer(),
          uri: String.t()
        }

  defimpl Jason.Encoder do
    @impl Jason.Encoder
    def encode(value, opts) do
      Jason.Encode.string(value.uri, opts)
    end
  end
end
