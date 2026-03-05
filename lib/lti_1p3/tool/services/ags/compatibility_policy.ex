defmodule Lti_1p3.Tool.Services.AGS.CompatibilityPolicy do
  @moduledoc """
  LMS compatibility hooks for tool AGS requests.
  """

  alias Lti_1p3.Services.HTTP.QueryFilters

  @spec apply(atom(), String.t(), keyword()) :: String.t()
  def apply(:list_line_items, request_url, opts) do
    profile = Keyword.get(opts, :compatibility, %{})
    default_limit = Map.get(profile, :default_line_items_limit)
    uri = URI.parse(request_url)
    query = if is_binary(uri.query), do: URI.decode_query(uri.query), else: %{}

    if is_integer(default_limit) and default_limit > 0 and not Map.has_key?(query, "limit") do
      QueryFilters.append_to_url(request_url, %{"limit" => Integer.to_string(default_limit)})
    else
      request_url
    end
  end

  def apply(_operation, request_url, _opts), do: request_url
end
