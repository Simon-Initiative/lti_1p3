defmodule Lti_1p3.Tool.Services.AGS.Parser do
  @moduledoc """
  AGS launch-claim and payload parsing.
  """

  alias Lti_1p3.Services.HTTP.LinkHeader
  alias Lti_1p3.Tool.Services.AGS.Endpoint
  alias Lti_1p3.Tool.Services.AGS.Errors
  alias Lti_1p3.Tool.Services.AGS.LineItem
  alias Lti_1p3.Tool.Services.AGS.Page
  alias Lti_1p3.Tool.Services.AGS.Result
  alias Lti_1p3.Tool.Services.AGS.Score

  @ags_claim_url "https://purl.imsglobal.org/spec/lti-ags/claim/endpoint"
  @lineitems_key "lineitems"
  @lineitem_key "lineitem"
  @scope_key "scope"
  @service_versions_key "service_versions"

  @spec parse_endpoint(map()) :: {:ok, Endpoint.t()} | {:error, Errors.error_map()}
  def parse_endpoint(claim_map) when is_map(claim_map) do
    with {:ok, claim} <- fetch_ags_claim(claim_map),
         {:ok, line_items_url} <- parse_line_items_url(claim),
         {:ok, scopes} <- parse_scopes(claim),
         {:ok, service_versions} <- parse_service_versions(claim) do
      {:ok,
       %Endpoint{
         line_items_url: line_items_url,
         line_item_url: Map.get(claim, @lineitem_key),
         scopes: scopes,
         service_versions: service_versions
       }}
    end
  end

  def parse_endpoint(_), do: {:error, Errors.invalid_claim(:invalid_claim_shape)}

  @spec parse_line_items_page(
          map() | list(),
          [{String.t(), String.t()}],
          pos_integer(),
          String.t()
        ) ::
          {:ok, Page.t(LineItem.t())} | {:error, Errors.error_map()}
  def parse_line_items_page(payload, headers, page_index, request_url)
      when is_list(payload) and is_list(headers) and is_integer(page_index) and page_index > 0 do
    with {:ok, items} <- parse_line_items(payload, :list_line_items) do
      {:ok,
       %Page{
         items: items,
         next_url: next_url(headers),
         page_index: page_index,
         request_url: request_url
       }}
    end
  end

  def parse_line_items_page(_payload, _headers, _page_index, _request_url) do
    {:error, Errors.invalid_payload(:list_line_items, :invalid_page_shape)}
  end

  @spec parse_results_page(map() | list(), [{String.t(), String.t()}], pos_integer(), String.t()) ::
          {:ok, Page.t(Result.t())} | {:error, Errors.error_map()}
  def parse_results_page(payload, headers, page_index, request_url)
      when is_list(payload) and is_list(headers) and is_integer(page_index) and page_index > 0 do
    with {:ok, items} <- parse_results(payload, :list_results) do
      {:ok,
       %Page{
         items: items,
         next_url: next_url(headers),
         page_index: page_index,
         request_url: request_url
       }}
    end
  end

  def parse_results_page(_payload, _headers, _page_index, _request_url) do
    {:error, Errors.invalid_payload(:list_results, :invalid_page_shape)}
  end

  @spec parse_line_item(map(), atom()) :: {:ok, LineItem.t()} | {:error, Errors.error_map()}
  def parse_line_item(raw, _operation) when is_map(raw) do
    {:ok,
     %LineItem{
       id: Map.get(raw, "id"),
       scoreMaximum: Map.get(raw, "scoreMaximum"),
       resourceId: Map.get(raw, "resourceId"),
       label: Map.get(raw, "label"),
       tag: Map.get(raw, "tag"),
       resourceLinkId: Map.get(raw, "resourceLinkId")
     }}
  end

  def parse_line_item(_raw, operation),
    do: {:error, Errors.invalid_payload(operation, :invalid_line_item)}

  @spec parse_result(map(), atom()) :: {:ok, Result.t()} | {:error, Errors.error_map()}
  def parse_result(raw, _operation) when is_map(raw) do
    {:ok,
     %Result{
       userId: Map.get(raw, "userId"),
       resultScore: Map.get(raw, "resultScore"),
       resultMaximum: Map.get(raw, "resultMaximum"),
       comment: Map.get(raw, "comment")
     }}
  end

  def parse_result(_raw, operation),
    do: {:error, Errors.invalid_payload(operation, :invalid_result)}

  @spec validate_score(Score.t() | map(), atom()) ::
          {:ok, Score.t()} | {:error, Errors.error_map()}
  def validate_score(%Score{} = score, _operation), do: {:ok, score}

  def validate_score(score_attrs, operation) when is_map(score_attrs) do
    attrs =
      score_attrs
      |> Enum.into(%{})

    required_fields = [:timestamp, :activityProgress, :gradingProgress, :userId]

    if Enum.all?(required_fields, &present?(Map.get(attrs, &1))) do
      {:ok,
       struct(Score, %{
         timestamp: Map.get(attrs, :timestamp),
         scoreGiven: Map.get(attrs, :scoreGiven),
         scoreMaximum: Map.get(attrs, :scoreMaximum),
         comment: Map.get(attrs, :comment),
         activityProgress: Map.get(attrs, :activityProgress),
         gradingProgress: Map.get(attrs, :gradingProgress),
         userId: Map.get(attrs, :userId)
       })}
    else
      {:error, Errors.invalid_attrs(operation, :missing_required_score_fields)}
    end
  end

  def validate_score(_, operation),
    do: {:error, Errors.invalid_attrs(operation, :invalid_score_shape)}

  @spec validate_line_item_attrs(map(), atom()) :: {:ok, map()} | {:error, Errors.error_map()}
  def validate_line_item_attrs(attrs, operation) when is_map(attrs) do
    case {Map.get(attrs, :scoreMaximum), Map.get(attrs, :label)} do
      {score_maximum, label}
      when (is_integer(score_maximum) or is_float(score_maximum)) and is_binary(label) and
             byte_size(label) > 0 ->
        {:ok, attrs}

      _ ->
        {:error, Errors.invalid_attrs(operation, :invalid_line_item_attrs)}
    end
  end

  def validate_line_item_attrs(_, operation),
    do: {:error, Errors.invalid_attrs(operation, :invalid_line_item_attrs)}

  defp fetch_ags_claim(claim_map) do
    case Map.get(claim_map, @ags_claim_url) do
      claim when is_map(claim) -> {:ok, claim}
      _ -> {:error, Errors.invalid_claim(:missing_ags_claim)}
    end
  end

  defp parse_line_items_url(claim) do
    case Map.get(claim, @lineitems_key) do
      url when is_binary(url) ->
        case URI.parse(url) do
          %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and is_binary(host) ->
            {:ok, url}

          _ ->
            {:error, Errors.invalid_claim(:invalid_lineitems_url)}
        end

      _ ->
        {:error, Errors.invalid_claim(:missing_lineitems_url)}
    end
  end

  defp parse_scopes(claim) do
    scopes =
      case Map.get(claim, @scope_key, []) do
        scopes when is_list(scopes) -> scopes
        scope when is_binary(scope) -> String.split(scope, " ", trim: true)
        _ -> []
      end

    {:ok, Enum.filter(scopes, &is_binary/1)}
  end

  defp parse_service_versions(claim) do
    versions =
      case Map.get(claim, @service_versions_key, []) do
        versions when is_list(versions) -> Enum.filter(versions, &is_binary/1)
        _ -> []
      end

    {:ok, versions}
  end

  defp parse_line_items(raw_items, operation) do
    raw_items
    |> Enum.reduce_while({:ok, []}, fn raw, {:ok, acc} ->
      case parse_line_item(raw, operation) do
        {:ok, line_item} -> {:cont, {:ok, [line_item | acc]}}
        {:error, _} = error -> {:halt, error}
      end
    end)
    |> case do
      {:ok, items} -> {:ok, Enum.reverse(items)}
      error -> error
    end
  end

  defp parse_results(raw_items, operation) do
    raw_items
    |> Enum.reduce_while({:ok, []}, fn raw, {:ok, acc} ->
      case parse_result(raw, operation) do
        {:ok, result} -> {:cont, {:ok, [result | acc]}}
        {:error, _} = error -> {:halt, error}
      end
    end)
    |> case do
      {:ok, items} -> {:ok, Enum.reverse(items)}
      error -> error
    end
  end

  defp next_url(headers) do
    headers
    |> Enum.find_value(fn
      {key, value} when is_binary(key) and is_binary(value) ->
        if String.downcase(key) == "link", do: value, else: nil

      _ ->
        nil
    end)
    |> LinkHeader.next_url()
  end

  defp present?(value) when is_binary(value), do: String.trim(value) != ""
  defp present?(nil), do: false
  defp present?(_value), do: true
end
