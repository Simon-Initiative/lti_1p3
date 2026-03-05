defmodule Lti_1p3.Tool.LaunchValidationTest do
  use Lti_1p3.Test.TestCase

  import Mox

  alias Lti_1p3.Test.MockHTTPoison
  alias Lti_1p3.Tool
  alias Lti_1p3.Tool.LaunchValidation

  setup :verify_on_exit!
  setup :set_mox_from_context

  setup do
    {:ok, supervisor_pid} =
      Lti_1p3.KeyProviderSupervisor.start_link(
        key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
        refresh_interval: 0
      )

    [{Lti_1p3.KeyProviders.MemoryKeyProvider, child_pid, :worker, _}] =
      Supervisor.which_children(supervisor_pid)

    Mox.allow(MockHTTPoison, self(), child_pid)

    Lti_1p3.KeyProviders.MemoryKeyProvider.clear_cache()

    on_exit(fn ->
      if Process.alive?(supervisor_pid), do: Process.exit(supervisor_pid, :normal)
    end)

    :ok
  end

  describe "validate_launch/3" do
    setup do
      jwk = jwk_fixture()
      registration = registration_fixture(%{tool_jwk_id: jwk.id})
      deployment_id = "1"

      _deployment =
        deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

      %{jwk: jwk, registration: registration, deployment_id: deployment_id, state: "some-state"}
    end

    test "returns normalized launch struct for valid launch", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)

      id_token = generate_id_token(jwk, jwk.kid, claims)

      expect(MockHTTPoison, :get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:ok, %Lti_1p3.Tool.Launch{} = launch} =
               Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state)

      assert launch.message_type == "LtiResourceLinkRequest"
      assert launch.deployment_id == deployment_id
      assert launch.raw_claims == nil
      assert launch.registration.id
    end

    test "can include raw claims in launch response", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)

      id_token = generate_id_token(jwk, jwk.kid, claims)

      expect(MockHTTPoison, :get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:ok, %Lti_1p3.Tool.Launch{raw_claims: raw_claims}} =
               Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state,
                 raw_claims: true
               )

      assert raw_claims["iss"] == claims["iss"]
    end

    test "supports deep-linking request validation scaffolding", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)
        |> Map.put(
          "https://purl.imsglobal.org/spec/lti/claim/message_type",
          "LtiDeepLinkingRequest"
        )
        |> Map.put("https://purl.imsglobal.org/spec/lti-dl/claim/deep_linking_settings", %{
          "deep_link_return_url" => "https://tool.example.com/return",
          "accept_types" => ["ltiResourceLink"],
          "accept_presentation_document_targets" => ["iframe"]
        })

      id_token = generate_id_token(jwk, jwk.kid, claims)

      expect(MockHTTPoison, :get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:ok, %Lti_1p3.Tool.Launch{message_type: "LtiDeepLinkingRequest"}} =
               Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state)
    end

    test "fails with explicit state stage on mismatched state", %{
      jwk: jwk,
      deployment_id: deployment_id
    } do
      claims =
        all_default_claims()
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)

      id_token = generate_id_token(jwk, jwk.kid, claims)

      assert {:error, %{stage: :state, reason: :invalid_oidc_state}} =
               Tool.validate_launch(
                 %{"state" => "request-state", "id_token" => id_token},
                 "session-state"
               )
    end

    test "fails with explicit jwt stage for malformed token", %{state: state} do
      assert {:error, %{stage: :registration, reason: :token_malformed}} =
               Tool.validate_launch(%{"state" => state, "id_token" => "malformed"}, state)
    end

    test "fails with explicit jwt stage for missing kid", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)

      signer = Joken.Signer.create("RS256", %{"pem" => jwk.pem})
      {:ok, claims} = Joken.generate_claims(%{}, claims)
      id_token = Joken.generate_and_sign!(%{}, claims, signer)

      assert {:error, %{stage: :jwt, reason: :missing_kid}} =
               Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state)
    end

    test "fails with explicit jwt stage for unsupported algorithm", %{
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)

      signer = Joken.Signer.create("HS256", "secret")
      {:ok, claims} = Joken.generate_claims(%{}, claims)
      id_token = Joken.generate_and_sign!(%{}, claims, signer)

      assert {:error, %{stage: :jwt, reason: :invalid_jwt_alg}} =
               Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state)
    end

    test "fails with explicit jwt stage when key resolution fails", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)

      id_token = generate_id_token(jwk, "unknown-kid", claims)

      expect(MockHTTPoison, :get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:error, %{stage: :jwt, reason: :key_not_found}} =
               Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state)
    end

    test "fails with explicit jwt stage for invalid audience", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> Map.put("aud", ["12345", "different-client-id"])
        |> Map.delete("azp")
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)

      id_token = generate_id_token(jwk, jwk.kid, claims)

      expect(MockHTTPoison, :get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:error, %{stage: :jwt, reason: :invalid_audience}} =
               Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state)
    end

    test "fails with explicit timestamps stage for expired token", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)
        |> Map.put(
          "exp",
          Timex.now() |> Timex.subtract(Timex.Duration.from_minutes(5)) |> Timex.to_unix()
        )

      id_token = generate_id_token(jwk, jwk.kid, claims)

      expect(MockHTTPoison, :get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:error,
              %{stage: :timestamps, reason: :invalid_jwt_timestamp, msg: "JWT exp is expired"}} =
               Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state)
    end

    test "fails with explicit nonce stage for duplicate nonce", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)
        |> Map.put("nonce", "duplicate nonce")

      id_token = generate_id_token(jwk, jwk.kid, claims)

      expect(MockHTTPoison, :get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:ok, _launch} =
               Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state)

      assert {:error, %{stage: :nonce, reason: :invalid_nonce, msg: "Duplicate nonce"}} =
               Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state)
    end

    test "fails with explicit message stage for unsupported message type", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/message_type", "InvalidMessageType")

      id_token = generate_id_token(jwk, jwk.kid, claims)

      expect(MockHTTPoison, :get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:error, %{stage: :message, reason: :invalid_message_type}} =
               Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state)
    end

    test "legacy LaunchValidation module delegates to the same pipeline", %{
      jwk: jwk,
      deployment_id: deployment_id,
      state: state
    } do
      claims =
        all_default_claims()
        |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)

      id_token = generate_id_token(jwk, jwk.kid, claims)

      expect(MockHTTPoison, :get, fn _url -> mock_get_jwk_keys(jwk) end)

      assert {:ok, %Lti_1p3.Tool.Launch{}} =
               LaunchValidation.validate(%{"state" => state, "id_token" => id_token}, state)
    end
  end

  test "emits stage and outcome telemetry events for tool launch" do
    handler_id = "tool-launch-telemetry-#{System.unique_integer([:positive])}"

    parent = self()

    :ok =
      :telemetry.attach_many(
        handler_id,
        [
          [:lti_1p3, :core, :validation, :stage],
          [:lti_1p3, :core, :validation, :outcome]
        ],
        fn event, _measurements, metadata, _config ->
          send(parent, {:telemetry_event, event, metadata})
        end,
        nil
      )

    on_exit(fn -> :telemetry.detach(handler_id) end)

    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})
    deployment_id = "1"

    _deployment =
      deployment_fixture(%{deployment_id: deployment_id, registration_id: registration.id})

    claims =
      all_default_claims()
      |> Map.put("https://purl.imsglobal.org/spec/lti/claim/deployment_id", deployment_id)

    id_token = generate_id_token(jwk, jwk.kid, claims)
    state = "some-state"

    expect(MockHTTPoison, :get, fn _url -> mock_get_jwk_keys(jwk) end)

    assert {:ok, %Lti_1p3.Tool.Launch{}} =
             Tool.validate_launch(%{"state" => state, "id_token" => id_token}, state)

    assert_receive {:telemetry_event, [:lti_1p3, :core, :validation, :stage],
                    %{stage: :state, result: :ok}}

    assert_receive {:telemetry_event, [:lti_1p3, :core, :validation, :outcome], %{result: :ok}}
  end
end
