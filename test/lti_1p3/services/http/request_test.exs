defmodule Lti_1p3.Services.HTTP.RequestTest do
  use ExUnit.Case, async: true

  alias Lti_1p3.Services.HTTP.Request

  test "with_bearer/2 appends authorization header" do
    assert Request.with_bearer([{"Content-Type", "application/json"}], "token-123") == [
             {"Content-Type", "application/json"},
             {"Authorization", "Bearer token-123"}
           ]
  end

  test "append_path/2 preserves query params" do
    assert Request.append_path("https://lms.example.edu/line_items/1?type=22", "scores") ==
             "https://lms.example.edu/line_items/1/scores?type=22"
  end
end
