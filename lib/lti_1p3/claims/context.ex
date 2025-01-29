defmodule Lti1p3.Claims.Context do
  @moduledoc """
  A struct representing the context claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#context-claim
  """
  @enforce_keys [:id]

  defstruct [
    :id,
    :label,
    :title,
    :type
  ]

  @type t() :: %__MODULE__{
          id: String.t(),
          label: String.t(),
          title: String.t(),
          type: String.t()
        }
end
