defmodule Lti_1p3.Platform.ResourceLink do
  @derive Jason.Encoder

  @enforce_keys [
    :id
  ]

  defstruct [
    :id,
    :description,
    :title
  ]

  @type t() :: %__MODULE__{
          id: String.t(),
          description: String.t(),
          title: String.t()
        }
end
