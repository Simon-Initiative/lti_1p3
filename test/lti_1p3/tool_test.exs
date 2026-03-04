defmodule Lti_1p3.ToolTest do
  use Lti_1p3.Test.TestCase

  alias Lti_1p3.Tool.Deployment
  alias Lti_1p3.Tool.Registration

  describe "Lti_1p3 Tool" do
    test "should create registration and deployment" do
      jwk = jwk_fixture()

      {:ok, registration} =
        Lti_1p3.Tool.create_registration(%Registration{
          issuer: "https://lti-ri.imsglobal.org",
          client_id: "12345",
          key_set_url: "some key_set_url",
          auth_token_url: "some auth_token_url",
          auth_login_url: "some auth_login_url",
          auth_server: "some auth_aud",
          tool_jwk_id: jwk.id
        })

      {:ok, deployment} =
        Lti_1p3.Tool.create_deployment(%Deployment{
          registration_id: registration.id,
          deployment_id: "some-deployment-id"
        })

      assert registration.issuer == "https://lti-ri.imsglobal.org"
      assert registration.client_id == "12345"
      assert registration.key_set_url == "some key_set_url"
      assert registration.auth_token_url == "some auth_token_url"
      assert registration.auth_login_url == "some auth_login_url"
      assert registration.auth_server == "some auth_aud"
      assert registration.tool_jwk_id == jwk.id

      assert deployment.registration_id == registration.id
      assert deployment.deployment_id == "some-deployment-id"
    end

    test "should get registration by issuer and client_id" do
      jwk = jwk_fixture()
      registration = registration_fixture(%{tool_jwk_id: jwk.id})

      issuer = "https://lti-ri.imsglobal.org"
      client_id = "12345"

      assert Lti_1p3.Tool.get_registration_by_issuer_client_id(issuer, client_id) == registration
    end

    test "should get registration deployment by issuer, client_id and deployment_id" do
      issuer = "https://lti-ri.imsglobal.org"
      client_id = "12345"
      deployment_id = "some-deployment-id"

      jwk = jwk_fixture()
      registration = registration_fixture(%{tool_jwk_id: jwk.id})

      deployment =
        deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

      assert Lti_1p3.Tool.get_registration_deployment(issuer, client_id, deployment_id) ==
               {registration, deployment}
    end

    test "login_redirect returns normalized payload" do
      jwk = jwk_fixture()

      registration_fixture(%{
        issuer: "https://lti-ri.imsglobal.org",
        client_id: "12345",
        key_set_url: "some key_set_url",
        auth_token_url: "some auth_token_url",
        auth_login_url: "https://platform.example.com/oidc",
        auth_server: "some auth_aud",
        tool_jwk_id: jwk.id
      })

      params = %{
        "iss" => "https://lti-ri.imsglobal.org",
        "client_id" => "12345",
        "login_hint" => "login-hint",
        "target_link_uri" => "https://tool.example.com/launch"
      }

      assert {:ok, %{state: state, redirect_url: redirect_url}} =
               Lti_1p3.Tool.login_redirect(params)

      assert is_binary(state)
      assert String.starts_with?(redirect_url, "https://platform.example.com/oidc?")
    end
  end
end
