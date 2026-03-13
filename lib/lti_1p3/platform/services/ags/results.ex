defmodule Lti_1p3.Platform.Services.AGS.Results do
  @moduledoc """
  Platform AGS result retrieval operations.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Platform.Services.AGS.Context
  alias Lti_1p3.Platform.Services.AGS.Errors
  alias Lti_1p3.Platform.Services.AGS.Page
  alias Lti_1p3.Platform.Services.AGS.Result
  alias Lti_1p3.Platform.Services.AGS.Telemetry
  alias Lti_1p3.Services.HTTP.QueryFilters

  @spec list(Context.t(), String.t(), keyword()) ::
          {:ok, Page.t(Result.t())} | {:error, Errors.error_map()}
  def list(%Context{} = context, id_or_url, opts \\ []) when is_binary(id_or_url) do
    with {:ok, filters} <- normalize_filters(opts),
         {:ok, raw_results} <-
           provider!().list_ags_results(
             context.deployment_id,
             context.context_id,
             id_or_url,
             filters
           ),
         {:ok, results} <- cast_results(raw_results) do
      Enum.each(results, fn result ->
        Telemetry.result(%{
          operation: :list_results,
          line_item_id: id_or_url,
          user_id: result.userId
        })
      end)

      {:ok,
       %Page{
         items: results,
         next_url: nil,
         page_index: Keyword.get(opts, :page_index, 1),
         request_opts: Enum.into(filters, %{})
       }}
    else
      {:error, %{} = error} ->
        {:error, error}

      {:error, reason} ->
        {:error, Errors.normalize_provider_error(:list_results, reason, id_or_url)}
    end
  end

  defp cast_results(raw_results) when is_list(raw_results) do
    raw_results
    |> Enum.reduce_while({:ok, []}, fn
      %Result{} = result, {:ok, acc} ->
        {:cont, {:ok, [result | acc]}}

      raw_result, {:ok, acc} when is_map(raw_result) ->
        {:cont,
         {:ok,
          [
            struct(Result, %{
              userId: Map.get(raw_result, :userId) || Map.get(raw_result, "userId"),
              resultScore:
                Map.get(raw_result, :resultScore) || Map.get(raw_result, "resultScore"),
              resultMaximum:
                Map.get(raw_result, :resultMaximum) || Map.get(raw_result, "resultMaximum"),
              comment: Map.get(raw_result, :comment) || Map.get(raw_result, "comment")
            })
            | acc
          ]}}

      _raw_result, _acc ->
        {:halt, {:error, Errors.internal(:list_results, :invalid_provider_result_shape)}}
    end)
    |> case do
      {:ok, results} -> {:ok, Enum.reverse(results)}
      error -> error
    end
  end

  defp cast_results(_raw_results),
    do: {:error, Errors.internal(:list_results, :invalid_provider_results_shape)}

  defp normalize_filters(opts) do
    opts
    |> Keyword.take([:limit, :user_id])
    |> QueryFilters.normalize()
    |> case do
      {:ok, filters} -> {:ok, filters}
      {:error, reason} -> {:error, Errors.invalid_opts(:list_results, reason)}
    end
  end
end
