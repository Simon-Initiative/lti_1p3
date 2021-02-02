defmodule Lti_1p3.LaunchValidationTest do
  use Lti_1p3.Test.TestCase

  import Mox

  alias Lti_1p3.Test.MockHTTPoison
  alias Lti_1p3.LaunchValidation

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "launch validation" do
    test "passes validation for a valid launch request" do
      %{params: params, session_state: session_state, jwk: jwk} = generate_lti_stubs()
      MockHTTPoison
      |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:ok, _lti_params, _cache_key} = LaunchValidation.validate(params, session_state)
    end
  end

  test "fails validation on missing oidc state" do
    %{params: params, session_state: session_state} = generate_lti_stubs(%{state: nil, session_state: nil})

    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :invalid_oidc_state, msg: "State from session is missing. Make sure cookies are enabled and configured correctly"}}
  end

  test "fails validation on invalid oidc state" do
    %{params: params, session_state: session_state} = generate_lti_stubs(%{state: "doesn't", session_state: "match"})

    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :invalid_oidc_state, msg: "State from OIDC request does not match session"}}
  end

  test "fails validation if registration doesn't exist for client id" do
    jwk = jwk_fixture()
    %{params: params, session_state: session_state} = generate_lti_stubs(%{
      kid: "one kid",
      registration_params: %{
        issuer: "some issuer",
        client_id: "some client_id",
        key_set_url: "some key_set_url",
        auth_token_url: "some auth_token_url",
        auth_login_url: "some auth_login_url",
        auth_server: "some auth_server",
        tool_jwk_id: jwk.id,
      },
    })

    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :invalid_registration, msg: "Registration with issuer \"https://lti-ri.imsglobal.org\" and client id \"12345\" not found", issuer: "https://lti-ri.imsglobal.org", client_id: "12345"}}
  end

  test "fails validation on missing id_token" do
    %{params: params, session_state: session_state} = generate_lti_stubs(%{id_token: nil})

    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :missing_param, msg: "Missing id_token"}}
  end

  test "fails validation on malformed id_token" do
    %{params: params, session_state: session_state} = generate_lti_stubs(%{id_token: "malformed3"})

      assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :token_malformed, msg: "Invalid JWT"}}
  end

  test "fails validation on invalid signature" do
    %{params: params, session_state: session_state, jwk: jwk} = generate_lti_stubs()

    other_jwk = jwk_fixture(%{kid: jwk.kid})
    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(other_jwk) end)

    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :signature_error, msg: "Invalid JWT"}}
  end

  test "fails validation on expired exp" do
    claims = all_default_claims()
      |> put_in(["exp"], Timex.now |> Timex.subtract(Timex.Duration.from_minutes(5)) |> Timex.to_unix)

    %{params: params, session_state: session_state, jwk: jwk} = generate_lti_stubs(%{claims: claims})
    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :invalid_jwt_timestamp, msg: "JWT exp is expired"}}
  end

  test "fails validation on token iat invalid" do
    claims = all_default_claims()
      |> put_in(["iat"], Timex.now |> Timex.add(Timex.Duration.from_minutes(5)) |> Timex.to_unix)

    %{params: params, session_state: session_state, jwk: jwk} = generate_lti_stubs(%{claims: claims})
    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :invalid_jwt_timestamp, msg: "JWT iat is invalid"}}
  end

  test "fails validation on both expired exp and iat invalid" do
    claims = all_default_claims()
      |> put_in(["exp"], Timex.now |> Timex.subtract(Timex.Duration.from_minutes(5)) |> Timex.to_unix)
      |> put_in(["iat"], Timex.now |> Timex.add(Timex.Duration.from_minutes(5)) |> Timex.to_unix)

    %{params: params, session_state: session_state, jwk: jwk} = generate_lti_stubs(%{claims: claims})
    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :invalid_jwt_timestamp, msg: "JWT exp and iat are invalid"}}
  end

  test "fails validation on duplicate nonce" do
    claims = all_default_claims()
      |> put_in(["nonce"], "duplicate nonce")
    %{params: params, session_state: session_state, jwk: jwk} = generate_lti_stubs(%{claims: claims})
    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    # passes on first attempt with a given nonce
    assert {:ok, _, _jwt_body} = LaunchValidation.validate(params, session_state)

    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    # fails on second attempt with a duplicate nonce
    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :invalid_nonce, msg: "Duplicate nonce"}}
  end

  test "fails validation if deployment doesn't exist" do
    claims = all_default_claims()
      |> put_in(["nonce"], UUID.uuid4())
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], "invalid_deployment_id")

    %{params: params, session_state: session_state, jwk: jwk, registration: registration} = generate_lti_stubs(%{claims: claims})
    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :invalid_deployment, msg: "Deployment with id \"invalid_deployment_id\" not found", registration_id: registration.id, deployment_id: "invalid_deployment_id"}}
  end

  test "fails validation on missing message type" do
    claims = all_default_claims()
      |> put_in(["nonce"], UUID.uuid4())
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/message_type"], nil)

    %{params: params, session_state: session_state, jwk: jwk} = generate_lti_stubs(%{claims: claims})
    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :invalid_message_type, msg: "Missing message type"}}
  end

  test "fails validation on invalid message type" do
    claims = all_default_claims()
      |> put_in(["nonce"], UUID.uuid4())
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/message_type"], "InvalidMessageType")

    %{params: params, session_state: session_state, jwk: jwk} = generate_lti_stubs(%{claims: claims})
    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) == {:error, %{reason: :invalid_message_type, msg: "Invalid or unsupported message type \"InvalidMessageType\""}}
  end

  test "caches lti launch params" do
    %{params: params, session_state: session_state, jwk: jwk} = generate_lti_stubs()
    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert {:ok, lti_params, cache_key} = LaunchValidation.validate(params, session_state)
    assert lti_params["sub"] == cache_key
  end

end
