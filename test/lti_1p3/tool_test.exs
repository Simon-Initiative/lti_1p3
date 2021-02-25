defmodule Lti_1p3.ToolTest do
  use Lti_1p3.Test.TestCase

  import Lti_1p3.Config

  alias Lti_1p3.Tool.Deployment
  alias Lti_1p3.Tool.Registration

  describe "Lti_1p3 Tool" do
    test "should create registration and deployment" do
      jwk = jwk_fixture()

      {:ok, registration} = Lti_1p3.Tool.create_registration(%Registration{
        issuer: "https://lti-ri.imsglobal.org",
        client_id: "12345",
        key_set_url: "some key_set_url",
        auth_token_url: "some auth_token_url",
        auth_login_url: "some auth_login_url",
        auth_server: "some auth_server",
        tool_jwk_id: jwk.id,
      })

      {:ok, deployment} = Lti_1p3.Tool.create_deployment(%Deployment{
        registration_id: registration.id,
        deployment_id: "some-deployment-id"
      })

      assert registration.issuer == "https://lti-ri.imsglobal.org"
      assert registration.client_id == "12345"
      assert registration.key_set_url == "some key_set_url"
      assert registration.auth_token_url == "some auth_token_url"
      assert registration.auth_login_url == "some auth_login_url"
      assert registration.auth_server == "some auth_server"
      assert registration.tool_jwk_id == jwk.id

      assert deployment.registration_id == registration.id
      assert deployment.deployment_id == "some-deployment-id"
    end

    test "should cache and fetch lti_params using key" do
      lti_params = all_default_claims()
      issuer = lti_params["iss"]
      client_id = lti_params["aud"]
      user_sub = lti_params["sub"]
      context_id = lti_params["https://purl.imsglobal.org/spec/lti/claim/context"]["id"]
      cache_key = Lti_1p3.Tool.lti_params_key(issuer, client_id, user_sub, context_id)
      exp = Timex.from_unix(lti_params["exp"])

      {:ok, %Lti_1p3.Tool.LtiParams{}} = provider!().create_or_update_lti_params(
        %Lti_1p3.Tool.LtiParams{key: cache_key, params: lti_params, exp: exp})

      fetched = Lti_1p3.Tool.get_lti_params_by_key(cache_key)
      assert fetched != nil
      assert fetched.params == lti_params
    end

    test "should update lti_params using key" do
      lti_params = all_default_claims()
      issuer = lti_params["iss"]
      client_id = lti_params["aud"]
      user_sub = lti_params["sub"]
      context_id = lti_params["https://purl.imsglobal.org/spec/lti/claim/context"]["id"]
      cache_key = Lti_1p3.Tool.lti_params_key(issuer, client_id, user_sub, context_id)
      exp = Timex.from_unix(lti_params["exp"])

      {:ok, %Lti_1p3.Tool.LtiParams{}} = provider!().create_or_update_lti_params(
        %Lti_1p3.Tool.LtiParams{key: cache_key, params: lti_params, exp: exp})

      fetched = Lti_1p3.Tool.get_lti_params_by_key(cache_key)
      assert fetched != nil
      assert fetched.params == lti_params

      new_context = %{
        "id" => "10338",
        "label" => "My Updated Course",
        "title" => "My Updated Course",
        "type" => ["Course"]
      }
      updated_lti_params = Map.put(lti_params, "https://purl.imsglobal.org/spec/lti/claim/context", new_context)

      updated_issuer = updated_lti_params["iss"]
      updated_client_id = updated_lti_params["aud"]
      updated_user_sub = updated_lti_params["sub"]
      updated_context_id = updated_lti_params["https://purl.imsglobal.org/spec/lti/claim/context"]["id"]
      updated_cache_key = Lti_1p3.Tool.lti_params_key(updated_issuer, updated_client_id, updated_user_sub, updated_context_id)

      {:ok, %Lti_1p3.Tool.LtiParams{}} = provider!().create_or_update_lti_params(
        %Lti_1p3.Tool.LtiParams{key: updated_cache_key, params: updated_lti_params, exp: exp})

      updated_fetched = Lti_1p3.Tool.get_lti_params_by_key(updated_cache_key)

      assert updated_fetched != nil
      assert updated_fetched.params == updated_lti_params
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
      deployment = deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

      assert Lti_1p3.Tool.get_registration_deployment(issuer, client_id, deployment_id) == {registration, deployment}
    end

  end
end
