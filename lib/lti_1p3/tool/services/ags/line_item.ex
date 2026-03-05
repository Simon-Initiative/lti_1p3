defmodule Lti_1p3.Tool.Services.AGS.LineItem do
  @moduledoc """
  AGS line item payload.
  """

  @derive {Jason.Encoder, except: [:id]}
  @enforce_keys [:scoreMaximum, :label, :resourceId]
  defstruct [:id, :scoreMaximum, :label, :resourceId, :tag, :resourceLinkId]

  @type t() :: %__MODULE__{
          id: String.t() | nil,
          scoreMaximum: float() | integer(),
          label: String.t(),
          resourceId: String.t() | integer(),
          tag: String.t() | nil,
          resourceLinkId: String.t() | nil
        }

  @line_item_prefix Lti_1p3.Config.get(:ags_line_item_prefix, "")

  @spec parse_resource_id(t()) :: String.t() | nil
  def parse_resource_id(%__MODULE__{} = line_item) do
    resource_id = to_string(line_item.resourceId)

    case resource_id do
      @line_item_prefix <> parsed_resource_id -> parsed_resource_id
      _ -> nil
    end
  end

  @spec to_resource_id(String.t() | integer()) :: String.t()
  def to_resource_id(resource_id) when is_integer(resource_id) do
    @line_item_prefix <> Integer.to_string(resource_id)
  end

  def to_resource_id(resource_id) when is_binary(resource_id) do
    if String.starts_with?(resource_id, @line_item_prefix) do
      resource_id
    else
      @line_item_prefix <> resource_id
    end
  end
end
