defmodule Lti_1p3.Tool.LaunchValidationTest do
  use Lti_1p3.Test.TestCase

  import Mox

  alias Lti_1p3.Test.MockHTTPoison
  alias Lti_1p3.Tool.LaunchValidation

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "launch validation" do
    setup do
      jwk = jwk_fixture()
      registration = registration_fixture(%{tool_jwk_id: jwk.id})
      deployment_id = "1"

      _deployment =
        deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

      state = "some-state"

      [jwk: jwk, registration: registration, deployment_id: deployment_id, state: state]
    end

    test "passes validation for a valid launch request and caches lti params", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)

      id_token = generate_id_token(jwk, jwk.kid, claims)
      params = %{"state" => state, "id_token" => id_token}

      MockHTTPoison
      |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:ok, _lti_params} = LaunchValidation.validate(params, state)
    end

    test "passes validation when aud claim is a list", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)
        |> Map.put("aud", ["12345"])

      id_token = generate_id_token(jwk, jwk.kid, claims)
      params = %{"state" => state, "id_token" => id_token}

      MockHTTPoison
      |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:ok, _lti_params} = LaunchValidation.validate(params, state)
    end

    test "passes validation when JWK is not Base64URL encoded", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)

      id_token = generate_id_token(jwk, jwk.kid, claims)
      params = %{"state" => state, "id_token" => id_token}

      transform_fn = fn map -> Map.update!(map, "n", &convert_to_base64_encoding(&1)) end

      MockHTTPoison
      |> expect(:get, fn _url -> mock_get_jwk_keys(jwk, transform: transform_fn) end)

      assert {:ok, _lti_params} = LaunchValidation.validate(params, state)
    end
  end

  test "fails validation on missing oidc state" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = nil

    claims =
      all_default_claims()
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)

    id_token = generate_id_token(jwk, jwk.kid, claims)
    params = %{"state" => state, "id_token" => id_token}

    assert LaunchValidation.validate(params, session_state) ==
             {:error,
              %{
                reason: :invalid_oidc_state,
                msg:
                  "State from session is missing. Make sure cookies are enabled and configured correctly"
              }}
  end

  test "fails validation on invalid oidc state" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "doesn't"
    session_state = "match"

    claims =
      all_default_claims()
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)

    id_token = generate_id_token(jwk, jwk.kid, claims)
    params = %{"state" => state, "id_token" => id_token}

    assert LaunchValidation.validate(params, session_state) ==
             {:error,
              %{
                reason: :invalid_oidc_state,
                msg: "State from OIDC request does not match session"
              }}
  end

  test "fails validation if registration doesn't exist for client id" do
    jwk = jwk_fixture()

    registration =
      registration_fixture(%{
        issuer: "some issuer",
        client_id: "some client_id",
        key_set_url: "some key_set_url",
        auth_token_url: "some auth_token_url",
        auth_login_url: "some auth_login_url",
        auth_server: "some auth_aud",
        tool_jwk_id: jwk.id
      })

    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = state

    claims =
      all_default_claims()
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)

    id_token = generate_id_token(jwk, jwk.kid, claims)
    params = %{"state" => state, "id_token" => id_token}

    assert LaunchValidation.validate(params, session_state) ==
             {:error,
              %{
                reason: :invalid_registration,
                msg:
                  "Registration with issuer \"https://lti-ri.imsglobal.org\" and client id \"12345\" not found",
                issuer: "https://lti-ri.imsglobal.org",
                client_id: "12345"
              }}
  end

  test "fails validation on missing id_token" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = state
    id_token = nil
    params = %{"state" => state, "id_token" => id_token}

    assert LaunchValidation.validate(params, session_state) ==
             {:error, %{reason: :missing_param, msg: "Missing id_token"}}
  end

  test "fails validation on malformed id_token" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = state
    id_token = "malformed"
    params = %{"state" => state, "id_token" => id_token}

    assert LaunchValidation.validate(params, session_state) ==
             {:error, %{reason: :token_malformed, msg: "Invalid JWT"}}
  end

  test "fails validation on invalid signature" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = state

    claims =
      all_default_claims()
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)

    id_token = generate_id_token(jwk, jwk.kid, claims)
    params = %{"state" => state, "id_token" => id_token}

    different_jwk = jwk_fixture(%{kid: jwk.kid})

    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(different_jwk) end)

    assert LaunchValidation.validate(params, session_state) ==
             {:error, %{reason: :signature_error, msg: "Invalid JWT"}}
  end

  test "fails validation on expired exp" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = state

    claims =
      all_default_claims()
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)
      |> put_in(
        ["exp"],
        Timex.now() |> Timex.subtract(Timex.Duration.from_minutes(5)) |> Timex.to_unix()
      )

    id_token = generate_id_token(jwk, jwk.kid, claims)
    params = %{"state" => state, "id_token" => id_token}

    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) ==
             {:error, %{reason: :invalid_jwt_timestamp, msg: "JWT exp is expired"}}
  end

  test "fails validation on token iat invalid" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = state

    claims =
      all_default_claims()
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)
      |> put_in(
        ["iat"],
        Timex.now() |> Timex.add(Timex.Duration.from_minutes(5)) |> Timex.to_unix()
      )

    id_token = generate_id_token(jwk, jwk.kid, claims)
    params = %{"state" => state, "id_token" => id_token}

    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) ==
             {:error, %{reason: :invalid_jwt_timestamp, msg: "JWT iat is invalid"}}
  end

  test "fails validation on both expired exp and iat invalid" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = state

    claims =
      all_default_claims()
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)
      |> put_in(
        ["exp"],
        Timex.now() |> Timex.subtract(Timex.Duration.from_minutes(5)) |> Timex.to_unix()
      )
      |> put_in(
        ["iat"],
        Timex.now() |> Timex.add(Timex.Duration.from_minutes(5)) |> Timex.to_unix()
      )

    id_token = generate_id_token(jwk, jwk.kid, claims)
    params = %{"state" => state, "id_token" => id_token}

    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) ==
             {:error, %{reason: :invalid_jwt_timestamp, msg: "JWT exp and iat are invalid"}}
  end

  test "fails validation on duplicate nonce" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = state

    claims =
      all_default_claims()
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)
      |> put_in(["nonce"], "duplicate nonce")

    id_token = generate_id_token(jwk, jwk.kid, claims)
    params = %{"state" => state, "id_token" => id_token}

    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    # passes on first attempt with a given nonce
    assert {:ok, _jwt_body} = LaunchValidation.validate(params, session_state)

    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    # fails on second attempt with a duplicate nonce
    assert LaunchValidation.validate(params, session_state) ==
             {:error, %{reason: :invalid_nonce, msg: "Duplicate nonce"}}
  end

  test "fails validation if deployment doesn't exist" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = state

    claims =
      all_default_claims()
      |> put_in(
        ["https://purl.imsglobal.org/spec/lti/claim/deployment_id"],
        "invalid_deployment_id"
      )

    id_token = generate_id_token(jwk, jwk.kid, claims)
    params = %{"state" => state, "id_token" => id_token}

    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) ==
             {:error,
              %{
                reason: :invalid_deployment,
                msg: "Deployment with id \"invalid_deployment_id\" not found",
                registration_id: registration.id,
                deployment_id: "invalid_deployment_id"
              }}
  end

  test "fails validation on missing message type" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = state

    claims =
      all_default_claims()
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/message_type"], nil)

    id_token = generate_id_token(jwk, jwk.kid, claims)
    params = %{"state" => state, "id_token" => id_token}

    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) ==
             {:error, %{reason: :invalid_message_type, msg: "Missing message type"}}
  end

  test "fails validation on invalid message type" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    state = "some-state"
    session_state = state

    claims =
      all_default_claims()
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/deployment_id"], deployment_id)
      |> put_in(["https://purl.imsglobal.org/spec/lti/claim/message_type"], "InvalidMessageType")

    id_token = generate_id_token(jwk, jwk.kid, claims)
    params = %{"state" => state, "id_token" => id_token}

    MockHTTPoison
    |> expect(:get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert LaunchValidation.validate(params, session_state) ==
             {:error,
              %{
                reason: :invalid_message_type,
                msg: "Invalid or unsupported message type \"InvalidMessageType\""
              }}
  end

  defp convert_to_base64_encoding(str) do
    String.replace(str, ["-", "_"], fn
      "-" -> "+"
      "_" -> "/"
      c -> c
    end)
  end
end
