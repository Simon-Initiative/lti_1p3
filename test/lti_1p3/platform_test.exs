defmodule Lti_1p3.PlatformTest do
  use Lti_1p3.Test.TestCase

  alias Lti_1p3.Platform.PlatformInstance

  describe "Lti_1p3 Platform" do
    test "should create platform instance" do
      {:ok, platform} = Lti_1p3.Platform.create_platform_instance(%PlatformInstance{
        client_id: "some-client-id",
        custom_params: "some-custom-params",
        description: "some-description",
        keyset_url: "some-keyset-url",
        login_url: "some-login-url",
        name: "some-name",
        redirect_uris: "some-redirect-uris",
        target_link_uri: "some-target-link-uri",
      })

      assert platform.id != nil
      assert platform.client_id == "some-client-id"
      assert platform.custom_params == "some-custom-params"
      assert platform.description == "some-description"
      assert platform.keyset_url == "some-keyset-url"
      assert platform.login_url == "some-login-url"
      assert platform.name == "some-name"
      assert platform.redirect_uris == "some-redirect-uris"
      assert platform.target_link_uri == "some-target-link-uri"
    end

  end
end
