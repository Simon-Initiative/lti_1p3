defmodule Lti_1p3.Tool.Services.AGS.LineItem do
  @derive {Jason.Encoder, except: [:id]}
  @enforce_keys [:scoreMaximum, :label, :resourceId]
  defstruct [:id, :scoreMaximum, :label, :resourceId]

  # The javascript naming convention here is important to match what the
  # LTI AGS standard expects

  @type t() :: %__MODULE__{
          id: String.t(),
          scoreMaximum: float,
          label: String.t(),
          resourceId: String.t()
        }

  @line_item_prefix Lti_1p3.Config.get(:ags_line_item_prefix, "")

  def parse_resource_id(%__MODULE__{} = line_item) do
    case line_item.resourceId do
      @line_item_prefix <> resource_id -> resource_id
      _ -> nil
    end
  end

  def to_resource_id(resource_id) do
    @line_item_prefix <> Integer.to_string(resource_id)
  end
end
