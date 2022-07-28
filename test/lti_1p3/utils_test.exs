defmodule Lti_1p3.UtilsTest do
  use Lti_1p3.Test.TestCase

  alias Lti_1p3.Utils

  describe "convert_map_to_base64url/1" do
    test "converts map to Base64URL encoding" do
      map = %{key: "KXHe3Ef6aEoTnkZpXkuA/++lTQ98"}
      expected_value = "KXHe3Ef6aEoTnkZpXkuA_--lTQ98"

      assert %{key: ^expected_value} = Utils.convert_map_to_base64url(map)
    end

    test "is idempotent when map is already Base64URL encoded" do
      base64url_encoded_value = "KXHe3Ef6aEoTnkZpXkuA_--lTQ98"
      map = %{key: base64url_encoded_value}

      assert map == Utils.convert_map_to_base64url(map)
    end

    test "ignores non-binary values" do
      map = %{key1: 123, key2: []}

      assert map == Utils.convert_map_to_base64url(map)
    end
  end
end
