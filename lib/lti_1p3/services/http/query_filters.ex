defmodule Lti_1p3.Services.HTTP.QueryFilters do
  @moduledoc """
  Query filter normalization and URL composition helpers.
  """

  @allowed_filters [:role, :limit, :resource_link_id, :status, :resource_id, :tag, :user_id]

  @spec normalize(keyword() | map()) :: {:ok, map()} | {:error, atom()}
  def normalize(filters) when filters in [nil, []], do: {:ok, %{}}

  def normalize(filters) when is_list(filters) do
    filters
    |> Enum.into(%{})
    |> normalize()
  end

  def normalize(filters) when is_map(filters) do
    Enum.reduce_while(filters, {:ok, %{}}, fn {key, value}, {:ok, acc} ->
      with {:ok, normalized_key} <- normalize_key(key),
           {:ok, normalized_value} <- normalize_value(normalized_key, value) do
        {:cont, {:ok, Map.put(acc, Atom.to_string(normalized_key), normalized_value)}}
      else
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  @spec append_to_url(String.t(), map()) :: String.t()
  def append_to_url(url, filters) when filters == %{}, do: url

  def append_to_url(url, filters) do
    uri = URI.parse(url)
    existing_query = if uri.query, do: URI.decode_query(uri.query), else: %{}
    query = URI.encode_query(Map.merge(existing_query, filters))

    uri
    |> Map.put(:query, query)
    |> URI.to_string()
  end

  defp normalize_key(key) when key in @allowed_filters, do: {:ok, key}

  defp normalize_key(key) when is_binary(key) do
    case Enum.find(@allowed_filters, &(Atom.to_string(&1) == key)) do
      nil -> {:error, :unsupported_filter}
      match -> {:ok, match}
    end
  end

  defp normalize_key(_), do: {:error, :unsupported_filter}

  defp normalize_value(:limit, value) when is_integer(value) and value > 0,
    do: {:ok, Integer.to_string(value)}

  defp normalize_value(:limit, _), do: {:error, :invalid_limit}

  defp normalize_value(_key, value) when is_binary(value) and byte_size(value) > 0,
    do: {:ok, value}

  defp normalize_value(_key, _value), do: {:error, :invalid_filter_value}
end
