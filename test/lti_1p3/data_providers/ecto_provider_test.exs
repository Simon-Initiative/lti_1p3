defmodule Lti_1p3.DataProviders.EctoProviderTest do
  use Lti_1p3.Test.TestCase

  alias Lti_1p3.DataProviders.EctoProvider

  describe "lti 1.3 library" do
    test "create and get valid registration" do
      {:ok, jwk} = EctoProvider.create_jwk(jwk_fixture())
      {:ok, registration} = EctoProvider.create_registration(%Lti_1p3.Tool.Registration{
        issuer: "some issuer",
        client_id: "some client_id",
        key_set_url: "some key_set_url",
        auth_token_url: "some auth_token_url",
        auth_login_url: "some auth_login_url",
        auth_server: "some auth_server",
        tool_jwk_id: jwk.id,
      })

      assert EctoProvider.get_registration_by_issuer_client_id("some issuer", "some client_id") == registration
    end

    test "create and get valid registration and deployment" do
      {:ok, jwk} = EctoProvider.create_jwk(jwk_fixture())
      {:ok, registration} = EctoProvider.create_registration(%Lti_1p3.Tool.Registration{
        issuer: "some issuer",
        client_id: "some client_id",
        key_set_url: "some key_set_url",
        auth_token_url: "some auth_token_url",
        auth_login_url: "some auth_login_url",
        auth_server: "some auth_server",
        tool_jwk_id: jwk.id,
      })

      {:ok, deployment} = EctoProvider.create_deployment(%Lti_1p3.Tool.Deployment{
        deployment_id: "some deployment_id",
        registration_id: registration.id
      })

      assert EctoProvider.get_rd_by_deployment_id(deployment.deployment_id) == {registration, deployment}
      assert EctoProvider.get_deployment(registration, deployment.deployment_id) == deployment
    end

    test "get registration by issuer and client_id" do
      issuer = "some issuer"
      client_id = "some client_id"
      {:ok, jwk} = EctoProvider.create_jwk(jwk_fixture())
      {:ok, registration} = EctoProvider.create_registration(%Lti_1p3.Tool.Registration{
        issuer: issuer,
        client_id: client_id,
        key_set_url: "some key_set_url",
        auth_token_url: "some auth_token_url",
        auth_login_url: "some auth_login_url",
        auth_server: "some auth_server",
        tool_jwk_id: jwk.id,
      })

      {:ok, _deployment} = EctoProvider.create_deployment(%Lti_1p3.Tool.Deployment{
        deployment_id: "some deployment_id",
        registration_id: registration.id
      })

      assert EctoProvider.get_registration_by_issuer_client_id(issuer, client_id) == registration
    end

    test "create and get valid jwk" do
      {:ok, jwk} = EctoProvider.create_jwk(jwk_fixture())

      active_jwk = EctoProvider.get_active_jwk()

      assert active_jwk == jwk
    end
  end

end
