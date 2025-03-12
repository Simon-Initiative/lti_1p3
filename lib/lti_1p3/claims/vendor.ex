defmodule Lti_1p3.Claims.Vendor do
  @moduledoc """
  A struct representing a vender extension claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#vendor-specific-extension-claims
  """
  @enforce_keys [:vendor, :value]

  defstruct [
    :vendor,
    :value
  ]

  @type t() :: %__MODULE__{
          vendor: String.t(),
          value: String.t() | %{String.t() => String.t()}
        }

  @doc """
  Create a new vendor extension claim.
  """
  def vendor(vendor, value), do: %__MODULE__{vendor: vendor, value: value}
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.Vendor do
  def get_key(%Lti_1p3.Claims.Vendor{vendor: vendor}), do: vendor

  def get_value(%Lti_1p3.Claims.Vendor{value: value}) do
    value
  end
end
