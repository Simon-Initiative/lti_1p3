defmodule Lti_1p3.Tool.Services.AGS.Endpoint do
  @moduledoc """
  Typed AGS endpoint configuration parsed from launch claims.
  """

  @enforce_keys [:line_items_url, :scopes, :service_versions]
  defstruct [:line_items_url, :line_item_url, :scopes, :service_versions]

  @type t() :: %__MODULE__{
          line_items_url: String.t(),
          line_item_url: String.t() | nil,
          scopes: [String.t()],
          service_versions: [String.t()]
        }
end
