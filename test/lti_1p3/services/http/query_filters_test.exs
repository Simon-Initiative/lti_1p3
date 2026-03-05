defmodule Lti_1p3.Services.HTTP.QueryFiltersTest do
  use ExUnit.Case, async: true

  alias Lti_1p3.Services.HTTP.QueryFilters

  test "normalizes supported filters" do
    assert {:ok,
            %{
              "limit" => "25",
              "role" => "Instructor",
              "status" => "Active"
            }} = QueryFilters.normalize(limit: 25, role: "Instructor", status: "Active")
  end

  test "returns errors for invalid filters" do
    assert {:error, :unsupported_filter} = QueryFilters.normalize(foo: "bar")
    assert {:error, :invalid_limit} = QueryFilters.normalize(limit: 0)
  end

  test "normalizes AGS filters" do
    assert {:ok, %{"resource_id" => "resource-1", "tag" => "gradebook", "user_id" => "u-1"}} =
             QueryFilters.normalize(resource_id: "resource-1", tag: "gradebook", user_id: "u-1")
  end

  test "appends filters into existing query" do
    url = "https://example.edu/memberships?page=1"

    assert QueryFilters.append_to_url(url, %{"limit" => "100", "role" => "Instructor"}) ==
             "https://example.edu/memberships?limit=100&page=1&role=Instructor"
  end
end
