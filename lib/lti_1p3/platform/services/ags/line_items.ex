defmodule Lti_1p3.Platform.Services.AGS.LineItems do
  @moduledoc """
  Platform AGS line item operations.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Platform.Services.AGS.Context
  alias Lti_1p3.Platform.Services.AGS.Errors
  alias Lti_1p3.Platform.Services.AGS.LineItem
  alias Lti_1p3.Platform.Services.AGS.Page
  alias Lti_1p3.Platform.Services.AGS.Telemetry
  alias Lti_1p3.Services.HTTP.QueryFilters

  @spec list(Context.t(), keyword()) :: {:ok, Page.t(LineItem.t())} | {:error, Errors.error_map()}
  def list(%Context{} = context, opts \\ []) do
    with {:ok, filters} <- normalize_filters(opts),
         {:ok, raw_items} <-
           provider!().list_ags_line_items(context.deployment_id, context.context_id, filters),
         {:ok, items} <- cast_line_items(raw_items, :list_line_items) do
      Enum.each(items, fn line_item ->
        Telemetry.line_item(%{operation: :list_line_items, line_item_id: line_item.id})
      end)

      {:ok,
       %Page{
         items: items,
         next_url: nil,
         page_index: Keyword.get(opts, :page_index, 1),
         request_opts: Enum.into(filters, %{})
       }}
    else
      {:error, %{} = error} ->
        {:error, error}

      {:error, reason} ->
        {:error, Errors.normalize_provider_error(:list_line_items, reason, "line_items")}
    end
  end

  @spec create(Context.t(), map()) :: {:ok, LineItem.t()} | {:error, Errors.error_map()}
  def create(%Context{} = context, attrs) when is_map(attrs) do
    with {:ok, attrs} <- validate_line_item_attrs(attrs, :create_line_item),
         {:ok, line_item} <-
           provider!().create_ags_line_item(context.deployment_id, context.context_id, attrs) do
      Telemetry.line_item(%{operation: :create_line_item, line_item_id: line_item.id})
      {:ok, line_item}
    else
      {:error, %{} = error} ->
        {:error, error}

      {:error, reason} ->
        {:error, Errors.normalize_provider_error(:create_line_item, reason, "line_items")}
    end
  end

  def create(_context, _attrs),
    do: {:error, Errors.invalid_attrs(:create_line_item, :invalid_shape)}

  @spec read(Context.t(), String.t()) :: {:ok, LineItem.t()} | {:error, Errors.error_map()}
  def read(%Context{} = context, id_or_url) when is_binary(id_or_url) do
    with {:ok, line_item} <-
           provider!().get_ags_line_item(context.deployment_id, context.context_id, id_or_url) do
      Telemetry.line_item(%{operation: :read_line_item, line_item_id: line_item.id})
      {:ok, line_item}
    else
      {:error, reason} ->
        {:error, Errors.normalize_provider_error(:read_line_item, reason, id_or_url)}
    end
  end

  @spec update(Context.t(), String.t(), map()) ::
          {:ok, LineItem.t()} | {:error, Errors.error_map()}
  def update(%Context{} = context, id_or_url, attrs)
      when is_binary(id_or_url) and is_map(attrs) do
    with {:ok, attrs} <- validate_line_item_attrs(attrs, :update_line_item),
         {:ok, line_item} <-
           provider!().update_ags_line_item(
             context.deployment_id,
             context.context_id,
             id_or_url,
             attrs
           ) do
      Telemetry.line_item(%{operation: :update_line_item, line_item_id: line_item.id})
      {:ok, line_item}
    else
      {:error, %{} = error} ->
        {:error, error}

      {:error, reason} ->
        {:error, Errors.normalize_provider_error(:update_line_item, reason, id_or_url)}
    end
  end

  def update(_context, _id_or_url, _attrs),
    do: {:error, Errors.invalid_attrs(:update_line_item, :invalid_shape)}

  @spec delete(Context.t(), String.t()) :: :ok | {:error, Errors.error_map()}
  def delete(%Context{} = context, id_or_url) when is_binary(id_or_url) do
    with :ok <-
           provider!().delete_ags_line_item(context.deployment_id, context.context_id, id_or_url) do
      Telemetry.line_item(%{operation: :delete_line_item, line_item_id: id_or_url})
      :ok
    else
      {:error, reason} ->
        {:error, Errors.normalize_provider_error(:delete_line_item, reason, id_or_url)}
    end
  end

  defp cast_line_items(raw_items, operation) when is_list(raw_items) do
    raw_items
    |> Enum.reduce_while({:ok, []}, fn
      %LineItem{} = line_item, {:ok, acc} ->
        {:cont, {:ok, [line_item | acc]}}

      item, {:ok, acc} when is_map(item) ->
        {:cont,
         {:ok,
          [
            struct(LineItem, %{
              id: Map.get(item, :id) || Map.get(item, "id"),
              scoreMaximum: Map.get(item, :scoreMaximum) || Map.get(item, "scoreMaximum"),
              label: Map.get(item, :label) || Map.get(item, "label"),
              resourceId: Map.get(item, :resourceId) || Map.get(item, "resourceId"),
              tag: Map.get(item, :tag) || Map.get(item, "tag"),
              resourceLinkId: Map.get(item, :resourceLinkId) || Map.get(item, "resourceLinkId")
            })
            | acc
          ]}}

      _item, _acc ->
        {:halt, {:error, Errors.internal(operation, :invalid_provider_line_item_shape)}}
    end)
    |> case do
      {:ok, items} -> {:ok, Enum.reverse(items)}
      error -> error
    end
  end

  defp cast_line_items(_raw_items, operation),
    do: {:error, Errors.internal(operation, :invalid_provider_line_items_shape)}

  defp validate_line_item_attrs(attrs, operation) do
    case {Map.get(attrs, :scoreMaximum), Map.get(attrs, :label)} do
      {score_maximum, label}
      when (is_integer(score_maximum) or is_float(score_maximum)) and is_binary(label) and
             byte_size(label) > 0 ->
        {:ok, attrs}

      _ ->
        {:error, Errors.invalid_attrs(operation, :invalid_line_item_attrs)}
    end
  end

  defp normalize_filters(opts) do
    opts
    |> Keyword.take([:resource_id, :tag, :limit])
    |> QueryFilters.normalize()
    |> case do
      {:ok, filters} -> {:ok, filters}
      {:error, reason} -> {:error, Errors.invalid_opts(:list_line_items, reason)}
    end
  end
end
