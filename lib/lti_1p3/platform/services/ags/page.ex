defmodule Lti_1p3.Platform.Services.AGS.Page do
  @moduledoc """
  A single platform AGS list page and metadata.
  """

  @enforce_keys [:items, :next_url, :page_index, :request_opts]
  defstruct [:items, :next_url, :page_index, :request_opts]

  @type t(item) :: %__MODULE__{
          items: [item],
          next_url: String.t() | nil,
          page_index: pos_integer(),
          request_opts: map()
        }
end
