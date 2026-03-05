defmodule Lti_1p3.Services.HTTP.Request do
  @moduledoc """
  Shared HTTP request helpers for authenticated service clients.
  """

  @spec with_bearer([{String.t(), String.t()}], String.t()) :: [{String.t(), String.t()}]
  def with_bearer(headers, token) when is_list(headers) and is_binary(token) do
    headers ++ [{"Authorization", "Bearer #{token}"}]
  end

  @spec append_path(String.t(), String.t()) :: String.t()
  def append_path(base_url, path_segment) when is_binary(base_url) and is_binary(path_segment) do
    uri = URI.parse(base_url)

    base_path = uri.path || ""
    normalized_path = String.trim_trailing(base_path, "/")
    normalized_segment = String.trim_leading(path_segment, "/")

    uri
    |> Map.put(:path, normalized_path <> "/" <> normalized_segment)
    |> URI.to_string()
  end
end
