defmodule Lti_1p3.Claims.PlatformInstance do
  @moduledoc """
  A struct representing the platform instance claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#platform-instance-claim
  """
  @enforce_keys [:guid]

  defstruct [
    :guid,
    :contact_email,
    :description,
    :name,
    :url,
    :product_family_code,
    :version
  ]

  @type t() :: %__MODULE__{
          guid: String.t(),
          contact_email: String.t(),
          description: String.t(),
          name: String.t(),
          url: String.t(),
          product_family_code: String.t(),
          version: String.t()
        }
end
