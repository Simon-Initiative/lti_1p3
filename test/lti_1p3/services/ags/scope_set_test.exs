defmodule Lti_1p3.Services.AGS.ScopeSetTest do
  use ExUnit.Case, async: true

  alias Lti_1p3.Services.AGS.ScopeSet

  test "maps required scopes by operation" do
    assert ScopeSet.required_scopes_for(:list_line_items) == [
             "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem",
             "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem.readonly"
           ]

    assert ScopeSet.required_scopes_for(:post_score) == [
             "https://purl.imsglobal.org/spec/lti-ags/scope/score"
           ]
  end

  test "parses scope strings and lists" do
    assert ScopeSet.parse_scope_string("a b a") == ["a", "b"]

    assert ScopeSet.parse_scope_string(["a", "b", "a", 1]) == ["a", "b"]
  end

  test "validates required scopes against available scopes" do
    assert ScopeSet.allows_any?(["a", "b"], ["x", "b"])
    refute ScopeSet.allows_any?(["a", "b"], ["x", "y"])
  end
end
