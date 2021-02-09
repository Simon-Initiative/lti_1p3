defmodule Lti_1p3Test do
  use Lti_1p3.Test.TestCase

  describe "LtiParams cache" do
    test "should create lti_params" do
      lti_params = all_default_claims()
      created = EctoProvider.create_or_update_lti_params(%Lti_1p3.Tool.LtiParams{
        key: "some-key",
        data: lti_params,
        exp: Timex.now() |> Timex.add(Timex.Duration.from_days(1)) |> Timex.to_unix()
      })

      assert created.data == lti_params
    end

    test "should fetch lti_params using key" do
      lti_params = all_default_claims()
      EctoProvider.cache_lti_params!("some-key", lti_params)

      fetched = EctoProvider.fetch_lti_params("some-key")
      assert fetched != nil
      assert fetched.data == lti_params
    end

    test "should update lti_params using key" do
      lti_params = all_default_claims()
      EctoProvider.cache_lti_params!("some-key", lti_params)

      fetched = EctoProvider.fetch_lti_params("some-key")
      assert fetched != nil
      assert fetched.data == lti_params

      new_context = %{
        "id" => "10338",
        "label" => "My Updated Course",
        "title" => "My Updated Course",
        "type" => ["Course"]
      }
      updated_lti_params = Map.put(lti_params, "https://purl.imsglobal.org/spec/lti/claim/context", new_context)
      EctoProvider.cache_lti_params!("some-key", updated_lti_params)
      updated_fetched = EctoProvider.fetch_lti_params("some-key")

      assert updated_fetched != nil
      assert updated_fetched.data == updated_lti_params
    end

  end
end
