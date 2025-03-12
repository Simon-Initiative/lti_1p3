defmodule Lti_1p3.Platform.AuthorizationRedirectTest do
  use Lti_1p3.Test.TestCase

  import Lti_1p3.Config
  import Mox

  alias Lti_1p3.Claims
  alias Lti_1p3.Platform.AuthorizationRedirect
  alias Lti_1p3.Test.MockHTTPoison
  alias Lti_1p3.Platform.LoginHint
  alias Lti_1p3.Platform.LoginHints
  alias Lti_1p3.Platform.PlatformInstance

  # Make sure mocks are verified when the test exits
  setup [:create_active_jwk, :verify_on_exit!]

  describe "authorize_redirect" do
    test "authorizes a valid redirect request" do
      %{
        state: state,
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        target_link_uri: target_link_uri,
        user: user
      } = generate_lti_platform_stubs()

      claims = [
        Claims.DeploymentId.deployment_id(deployment_id),
        Claims.TargetLinkUri.target_link_uri("some-valid-url"),
        Claims.ResourceLink.resource_link("some-resource-link-id"),
        Claims.Roles.roles([])
      ]

      assert {:ok, ^target_link_uri, ^state, id_token} =
               AuthorizationRedirect.authorize_redirect(params, user, issuer, claims)

      # validate the id_token returned is signed correctly
      {:ok, active_jwk} = provider!().get_active_jwk()

      MockHTTPoison
      |> expect(:get, fn _url -> mock_get_jwk_keys(active_jwk) end)

      assert {:ok, jwt} = Lti_1p3.Utils.validate_jwt_signature(id_token, "some-keyset-url")

      assert jwt["exp"]
      assert jwt["iat"]
      assert jwt["nbf"]
      assert jwt["nonce"]

      assert jwt["iss"] == issuer
      assert jwt["aud"] == "some-client-id"
      assert jwt["sub"] == user.sub
      assert jwt["given_name"] == user.given_name
      assert jwt["family_name"] == user.family_name
      assert jwt["middle_name"] == user.middle_name
      assert jwt["name"] == user.name
      assert jwt["email"] == user.email
      assert jwt["locale"] == user.locale
      assert jwt["picture"] == user.picture

      assert jwt["https://purl.imsglobal.org/spec/lti/claim/message_type"] ==
               "LtiResourceLinkRequest"

      assert jwt["https://purl.imsglobal.org/spec/lti/claim/version"] == "1.3.0"
      assert jwt["https://purl.imsglobal.org/spec/lti/claim/deployment_id"] == deployment_id
      assert jwt["https://purl.imsglobal.org/spec/lti/claim/target_link_uri"] == "some-valid-url"

      assert jwt["https://purl.imsglobal.org/spec/lti/claim/resource_link"] ==
               %{"id" => "some-resource-link-id"}

      assert jwt["https://purl.imsglobal.org/spec/lti/claim/roles"] == []
    end

    test "fails on missing oidc params" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user
      } = generate_lti_platform_stubs()

      params =
        params
        |> Map.drop(["scope", "nonce"])

      claims = [
        Claims.DeploymentId.deployment_id(deployment_id),
        Claims.TargetLinkUri.target_link_uri("some-valid-url"),
        Claims.ResourceLink.resource_link("some-resource-link-id"),
        Claims.Roles.roles([])
      ]

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, claims) ==
               {:error,
                %{
                  reason: :invalid_oidc_params,
                  msg: "Invalid OIDC params. The following parameters are missing: nonce, scope",
                  missing_params: ["nonce", "scope"]
                }}
    end

    test "fails on incorrect oidc scope" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user
      } = generate_lti_platform_stubs()

      params =
        params
        |> Map.put("scope", "invalid_scope")

      claims = [
        Claims.DeploymentId.deployment_id(deployment_id),
        Claims.TargetLinkUri.target_link_uri("some-valid-url"),
        Claims.ResourceLink.resource_link("some-resource-link-id"),
        Claims.Roles.roles([])
      ]

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, claims) ==
               {:error,
                %{
                  reason: :invalid_oidc_scope,
                  msg: "Invalid OIDC scope: invalid_scope. Scope must be 'openid'"
                }}
    end

    test "fails on invalid login_hint user session" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user
      } = generate_lti_platform_stubs()

      other_user = lti_1p3_user()

      params =
        params
        |> Map.put("login_hint", "#{other_user.id}")

      claims = [
        Claims.DeploymentId.deployment_id(deployment_id),
        Claims.TargetLinkUri.target_link_uri("some-valid-url"),
        Claims.ResourceLink.resource_link("some-resource-link-id"),
        Claims.Roles.roles([])
      ]

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, claims) ==
               {:error,
                %{
                  reason: :invalid_login_hint,
                  msg: "Login hint must be linked with an active user session"
                }}
    end

    test "fails on invalid client_id" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user
      } = generate_lti_platform_stubs()

      params =
        params
        |> Map.put("client_id", "some-other-client-id")

      claims = [
        Claims.DeploymentId.deployment_id(deployment_id),
        Claims.TargetLinkUri.target_link_uri("some-valid-url"),
        Claims.ResourceLink.resource_link("some-resource-link-id"),
        Claims.Roles.roles([])
      ]

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, claims) ==
               {:error,
                %{
                  reason: :client_not_registered,
                  msg: "No platform exists with client id 'some-other-client-id'"
                }}
    end

    test "fails on invalid redirect_uri" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user
      } = generate_lti_platform_stubs()

      params =
        params
        |> Map.put("redirect_uri", "some-invalid_redirect-uri")

      claims = [
        Claims.DeploymentId.deployment_id(deployment_id),
        Claims.TargetLinkUri.target_link_uri("some-valid-url"),
        Claims.ResourceLink.resource_link("some-resource-link-id"),
        Claims.Roles.roles([])
      ]

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, claims) ==
               {:error,
                %{
                  reason: :unauthorized_redirect_uri,
                  msg: "Redirect URI not authorized in requested context"
                }}
    end

    test "fails on duplicate nonce" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user
      } = generate_lti_platform_stubs()

      claims = [
        Claims.DeploymentId.deployment_id(deployment_id),
        Claims.TargetLinkUri.target_link_uri("some-valid-url"),
        Claims.ResourceLink.resource_link("some-resource-link-id"),
        Claims.Roles.roles([])
      ]

      assert {:ok, _target_link_uri, _state, _id_token} =
               AuthorizationRedirect.authorize_redirect(params, user, issuer, claims)

      # try again with the same nonce
      assert {:error, %{reason: :invalid_nonce, msg: "Duplicate nonce"}} ==
               AuthorizationRedirect.authorize_redirect(params, user, issuer, claims)
    end

    test "fails on missing required claims" do
      %{
        issuer: issuer,
        deployment_id: _deployment_id,
        params: params,
        user: user
      } = generate_lti_platform_stubs()

      claims = []

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, claims) ==
               {:error,
                %{
                  reason: :missing_required_claims,
                  msg:
                    "Missing required claims: https://purl.imsglobal.org/spec/lti/claim/deployment_id, https://purl.imsglobal.org/spec/lti/claim/target_link_uri, https://purl.imsglobal.org/spec/lti/claim/resource_link, https://purl.imsglobal.org/spec/lti/claim/roles",
                  missing_claims: [
                    "https://purl.imsglobal.org/spec/lti/claim/deployment_id",
                    "https://purl.imsglobal.org/spec/lti/claim/target_link_uri",
                    "https://purl.imsglobal.org/spec/lti/claim/resource_link",
                    "https://purl.imsglobal.org/spec/lti/claim/roles"
                  ]
                }}
    end

    test "fails on missing required roles claim" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user
      } = generate_lti_platform_stubs()

      claims = [
        Claims.DeploymentId.deployment_id(deployment_id),
        Claims.TargetLinkUri.target_link_uri("some-valid-url"),
        Claims.ResourceLink.resource_link("some-resource-link-id")
      ]

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, claims) ==
               {:error,
                %{
                  reason: :missing_required_claims,
                  msg: "Missing required claims: https://purl.imsglobal.org/spec/lti/claim/roles",
                  missing_claims: ["https://purl.imsglobal.org/spec/lti/claim/roles"]
                }}
    end
  end

  def create_active_jwk(_context) do
    jwk = jwk_fixture()

    %{jwk: jwk}
  end

  def generate_lti_platform_stubs(args \\ %{}) do
    user = args[:user] || lti_1p3_user()
    {:ok, %LoginHint{value: login_hint}} = LoginHints.create_login_hint(user.id)

    %{
      target_link_uri: target_link_uri,
      nonce: nonce,
      client_id: client_id,
      state: state,
      lti_message_hint: lti_message_hint,
      user: user,
      deployment_id: deployment_id
    } =
      %{
        target_link_uri: "some-valid-url",
        nonce: "some-nonce",
        client_id: "some-client-id",
        state: "some-state",
        lti_message_hint: "some-lti-message-hint",
        user: user,
        deployment_id: "some-deployment-id"
      }
      |> Map.merge(args)

    {:ok, platform_instance} =
      provider!().create_platform_instance(%PlatformInstance{
        name: "some-platform",
        target_link_uri: target_link_uri,
        client_id: client_id,
        login_url: "some-login-url",
        keyset_url: "some-keyset-url",
        redirect_uris: "some-valid-url"
      })

    issuer = "some-issuer"

    params = %{
      "client_id" => client_id,
      "login_hint" => login_hint,
      "lti_message_hint" => lti_message_hint,
      "nonce" => nonce,
      "prompt" => "none",
      "redirect_uri" => target_link_uri,
      "response_mode" => "form_post",
      "response_type" => "id_token",
      "scope" => "openid",
      "state" => state
    }

    %{
      user: user,
      state: state,
      issuer: issuer,
      deployment_id: deployment_id,
      params: params,
      target_link_uri: target_link_uri,
      nonce: nonce,
      client_id: client_id,
      platform_instance: platform_instance
    }
  end
end
