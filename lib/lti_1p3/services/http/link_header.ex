defmodule Lti_1p3.Services.HTTP.LinkHeader do
  @moduledoc """
  Helpers for parsing RFC5988-style HTTP `Link` headers.
  """

  @type link :: %{url: String.t(), rel: String.t() | nil}

  @spec parse(String.t() | nil) :: [link()]
  def parse(nil), do: []
  def parse(""), do: []

  def parse(header) when is_binary(header) do
    header
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_segment/1)
    |> Enum.reject(&is_nil/1)
  end

  @spec next_url(String.t() | nil) :: String.t() | nil
  def next_url(header) do
    header
    |> parse()
    |> Enum.find_value(fn
      %{rel: "next", url: url} -> url
      _ -> nil
    end)
  end

  defp parse_segment(segment) do
    with [url_part | attrs] <- String.split(segment, ";"),
         url when url != "" <- parse_url(url_part) do
      %{url: url, rel: parse_rel(attrs)}
    else
      _ -> nil
    end
  end

  defp parse_url(url_part) do
    url_part = String.trim(url_part)

    case {String.starts_with?(url_part, "<"), String.ends_with?(url_part, ">")} do
      {true, true} ->
        url_part
        |> String.trim_leading("<")
        |> String.trim_trailing(">")

      _ ->
        ""
    end
  end

  defp parse_rel(attrs) do
    attrs
    |> Enum.map(&String.trim/1)
    |> Enum.find_value(fn
      "rel=\"" <> rest -> String.trim_trailing(rest, "\"")
      "rel=" <> rel -> rel
      _ -> nil
    end)
  end
end
