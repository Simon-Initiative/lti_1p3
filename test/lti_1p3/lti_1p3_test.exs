defmodule Lti_1p3Test do
  use Lti_1p3.Test.TestCase

  import Lti_1p3.Config

  describe "LtiParams cache" do
    test "should cache and fetch lti_params using key" do
      lti_params = all_default_claims()
      sub = lti_params["sub"]
      exp = Timex.from_unix(lti_params["exp"])

      %Lti_1p3.Tool.LtiParams{sub: sub, params: lti_params, exp: exp}
      |> provider!().create_or_update_lti_params()

      fetched = Lti_1p3.Tool.get_lti_params_by_sub(sub)
      assert fetched != nil
      assert fetched.params == lti_params
    end

    test "should update lti_params using key" do
      lti_params = all_default_claims()
      sub = lti_params["sub"]
      exp = Timex.from_unix(lti_params["exp"])

      %Lti_1p3.Tool.LtiParams{sub: sub, params: lti_params, exp: exp}
      |> provider!().create_or_update_lti_params()

      fetched = Lti_1p3.Tool.get_lti_params_by_sub(sub)
      assert fetched != nil
      assert fetched.params == lti_params

      new_context = %{
        "id" => "10338",
        "label" => "My Updated Course",
        "title" => "My Updated Course",
        "type" => ["Course"]
      }
      updated_lti_params = Map.put(lti_params, "https://purl.imsglobal.org/spec/lti/claim/context", new_context)

      %Lti_1p3.Tool.LtiParams{sub: sub, params: updated_lti_params, exp: exp}
      |> provider!().create_or_update_lti_params()

      updated_fetched = Lti_1p3.Tool.get_lti_params_by_sub(sub)

      assert updated_fetched != nil
      assert updated_fetched.params == updated_lti_params
    end

  end
end
