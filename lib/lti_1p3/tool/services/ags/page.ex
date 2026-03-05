defmodule Lti_1p3.Tool.Services.AGS.Page do
  @moduledoc """
  A single AGS list page and traversal metadata.
  """

  @enforce_keys [:items, :next_url, :page_index, :request_url]
  defstruct [:items, :next_url, :page_index, :request_url]

  @type t(item) :: %__MODULE__{
          items: [item],
          next_url: String.t() | nil,
          page_index: pos_integer(),
          request_url: String.t()
        }
end
