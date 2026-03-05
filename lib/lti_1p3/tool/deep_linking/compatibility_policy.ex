defmodule Lti_1p3.Tool.DeepLinking.CompatibilityPolicy do
  @moduledoc """
  Compatibility hooks for LMS variance handling of content item types.
  """

  alias Lti_1p3.Tool.DeepLinking.Errors

  @type strategy :: :strict | :filter_unsupported

  @spec apply([map()], [String.t()], keyword()) :: {:ok, [map()]} | {:error, Errors.t()}
  def apply(items, accepted_types, opts \\ []) when is_list(items) and is_list(accepted_types) do
    strategy = Keyword.get(opts, :unsupported_type_strategy, :strict)

    accepted_set = MapSet.new(accepted_types)

    Enum.reduce_while(items, {:ok, []}, fn item, {:ok, acc} ->
      type = Map.get(item, "type")

      if MapSet.member?(accepted_set, type) do
        {:cont, {:ok, [item | acc]}}
      else
        case strategy do
          :strict ->
            {:halt,
             Errors.error(
               :response,
               :unsupported_content_item_type,
               "Content item type #{type} is not accepted by launch settings",
               %{type: type, accepted_types: accepted_types}
             )}

          :filter_unsupported ->
            {:cont, {:ok, acc}}
        end
      end
    end)
    |> case do
      {:ok, filtered_items} ->
        filtered_items = Enum.reverse(filtered_items)

        if filtered_items == [] do
          Errors.error(
            :response,
            :no_supported_content_items,
            "No supported content items remain after compatibility filtering",
            %{accepted_types: accepted_types}
          )
        else
          {:ok, filtered_items}
        end

      {:error, _} = error ->
        error
    end
  end
end
