defmodule Lti_1p3.Claims.ResourceLink do
  @moduledoc """
  A struct representing the resource link claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#resource-link-claim
  """
  @enforce_keys [:id]

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
