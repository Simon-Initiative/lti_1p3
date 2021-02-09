defmodule Lti_1p3.Platform.AuthorizationRedirectTest do
  use Lti_1p3.Test.TestCase

  import Lti_1p3.Config
  import Mox

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
        user: user,
      } = generate_lti_platform_stubs()

      assert {:ok, ^target_link_uri, ^state, id_token} = AuthorizationRedirect.authorize_redirect(params, user, issuer, deployment_id)

      # validate the id_token returned is signed correctly
      {:ok, active_jwk} = provider!().get_active_jwk()
      MockHTTPoison
      |> expect(:get, fn _url -> mock_get_jwk_keys(active_jwk) end)

      assert {:ok, _jwt} = Lti_1p3.Utils.validate_jwt_signature(id_token, "some-keyset-url")
    end

    test "fails on missing oidc params" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user,
      } = generate_lti_platform_stubs()

      params = params
        |> Map.drop(["scope", "nonce"])

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, deployment_id) == {:error, %{reason: :invalid_oidc_params, msg: "Invalid OIDC params. The following parameters are missing: nonce, scope", missing_params: ["nonce", "scope"]}}
    end

    test "fails on incorrect oidc scope" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user,
      } = generate_lti_platform_stubs()

      params = params
        |> Map.put("scope", "invalid_scope")

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, deployment_id) == {:error, %{reason: :invalid_oidc_scope, msg: "Invalid OIDC scope: invalid_scope. Scope must be 'openid'"}}
    end

    test "fails on invalid login_hint user session" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user,
      } = generate_lti_platform_stubs()

      other_user = lti_1p3_user_fixture()

      params = params
        |> Map.put("login_hint", "#{other_user.id}")

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, deployment_id) == {:error, %{reason: :invalid_login_hint, msg: "Login hint must be linked with an active user session"}}
    end

    test "fails on invalid client_id" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user,
      } = generate_lti_platform_stubs()

      params = params
        |> Map.put("client_id", "some-other-client-id")

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, deployment_id) == {:error, %{reason: :client_not_registered, msg: "No platform exists with client id 'some-other-client-id'"}}
    end

    test "fails on invalid redirect_uri" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user,
      } = generate_lti_platform_stubs()

      params = params
        |> Map.put("redirect_uri", "some-invalid_redirect-uri")

      assert AuthorizationRedirect.authorize_redirect(params, user, issuer, deployment_id) == {:error, %{reason: :unauthorized_redirect_uri, msg: "Redirect URI not authorized in requested context"}}
    end

    test "fails on duplicate nonce" do
      %{
        issuer: issuer,
        deployment_id: deployment_id,
        params: params,
        user: user,
      } = generate_lti_platform_stubs()

      assert {:ok, _target_link_uri, _state, _id_token} = AuthorizationRedirect.authorize_redirect(params, user, issuer, deployment_id)

      # try again with the same nonce
      assert {:error, %{reason: :invalid_nonce, msg: "Duplicate nonce"}} == AuthorizationRedirect.authorize_redirect(params, user, issuer, deployment_id)
    end
  end

  def create_active_jwk(_context) do
    {:ok, jwk} = provider!().create_jwk(jwk_fixture())

    %{jwk: jwk}
  end

  def generate_lti_platform_stubs(args \\ %{}) do
    user = args[:user] || lti_1p3_user_fixture()
    {:ok, %LoginHint{value: login_hint}} = LoginHints.create_login_hint(user.id)
    %{
      target_link_uri: target_link_uri,
      nonce: nonce,
      client_id: client_id,
      state: state,
      lti_message_hint: lti_message_hint,
      user: user,
      deployment_id: deployment_id,
    } = %{
      target_link_uri: "some-valid-url",
      nonce: "some-nonce",
      client_id: "some-client-id",
      state: "some-state",
      lti_message_hint: "some-lti-message-hint",
      user: user,
      deployment_id: "some-deployment-id",
    } |> Map.merge(args)

    {:ok, platform_instance} = provider!().create_platform_instance(%PlatformInstance{
      name: "some-platform",
      target_link_uri: target_link_uri,
      client_id: client_id,
      login_url: "some-login-url",
      keyset_url: "some-keyset-url",
      redirect_uris: "some-valid-url"
    })

    jwk = jwk_fixture()

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
      "state" => state,
    }

    %{user: user, state: state, issuer: issuer, deployment_id: deployment_id, params: params, jwk: jwk, target_link_uri: target_link_uri, nonce: nonce, client_id: client_id, platform_instance: platform_instance}
  end

end
