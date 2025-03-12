defmodule Lti_1p3.Claims.Custom do
  @moduledoc """
  A struct representing the custom claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#custom-properties-and-variable-substitution
  """
  @enforce_keys [:custom]

  defstruct [
    :custom
  ]

  @type t() :: %__MODULE__{
          custom: %{String.t() => String.t()}
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/custom"

  @doc """
  Create a new custom claim.
  """
  def custom(custom), do: %__MODULE__{custom: custom}
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.Custom do
  def get_key(_), do: Lti_1p3.Claims.Custom.key()

  def get_value(%Lti_1p3.Claims.Custom{custom: custom}) do
    custom
  end
end
