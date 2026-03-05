defmodule Lti_1p3.Services.HTTP.LinkHeaderTest do
  use ExUnit.Case, async: true

  alias Lti_1p3.Services.HTTP.LinkHeader

  test "parses link entries" do
    header =
      "<https://example.edu/memberships?page=2>; rel=\"next\", <https://example.edu/memberships?page=1>; rel=\"prev\""

    assert [
             %{url: "https://example.edu/memberships?page=2", rel: "next"},
             %{url: "https://example.edu/memberships?page=1", rel: "prev"}
           ] = LinkHeader.parse(header)
  end

  test "extracts next url" do
    header =
      "<https://example.edu/memberships?page=2>; rel=\"next\", <https://example.edu/memberships?page=5>; rel=\"last\""

    assert LinkHeader.next_url(header) == "https://example.edu/memberships?page=2"
  end

  test "handles missing headers" do
    assert LinkHeader.parse(nil) == []
    assert LinkHeader.next_url(nil) == nil
  end
end
