defmodule Lti_1p3.Tool.DeepLinkingTest do
  use Lti_1p3.Test.TestCase

  alias Lti_1p3.DeepLinking.ClaimKeys
  alias Lti_1p3.Tool
  alias Lti_1p3.Tool.DeepLinking

  describe "validate_deep_linking_request/1" do
    test "returns typed request and settings" do
      claims = deep_linking_claims()

      assert {:ok, request} = Tool.validate_deep_linking_request(claims)
      assert request.message_type == "LtiDeepLinkingRequest"
      assert request.settings.deep_link_return_url == "https://tool.example.com/deep_link_return"
      assert request.settings.accept_types == ["ltiResourceLink", "link"]
    end

    test "returns structured error for malformed settings" do
      claims =
        deep_linking_claims()
        |> put_in([ClaimKeys.key(:deep_linking_settings), "accept_types"], nil)

      assert {:error, %{reason: :invalid_deep_linking_settings, stage: :request}} =
               Tool.validate_deep_linking_request(claims)
    end
  end

  describe "launch validation dispatch integration" do
    test "fails message validation when deep-linking settings are incomplete" do
      claims =
        deep_linking_claims()
        |> put_in([ClaimKeys.key(:deep_linking_settings), "accept_types"], [])

      assert {:error, %{reason: :invalid_deep_linking_settings}} =
               Lti_1p3.Tool.MessageDispatch.validate(claims)
    end
  end

  describe "deep_linking_content_item/2" do
    test "builds typed content items" do
      assert {:ok, item} =
               Tool.deep_linking_content_item(:lti_resource_link, %{
                 "url" => "https://tool.example.com/resource/1",
                 "title" => "Example Item",
                 "lineItem" => %{"scoreMaximum" => 100}
               })

      assert item.type == "ltiResourceLink"
      assert item.line_item["scoreMaximum"] == 100
    end

    test "rejects unsupported subtype" do
      assert {:error, %{reason: :unsupported_content_item_type, stage: :content_item}} =
               Tool.deep_linking_content_item("unknown", %{})
    end
  end

  describe "build_deep_linking_response/3" do
    test "builds signed response and includes correlated data claim" do
      jwk = jwk_fixture()
      claims = deep_linking_claims()
      assert {:ok, request} = Tool.validate_deep_linking_request(claims)

      assert {:ok, item} =
               Tool.deep_linking_content_item(:link, %{
                 "url" => "https://tool.example.com/activity",
                 "title" => "Activity"
               })

      assert {:ok, %{jwt: jwt, return_url: "https://tool.example.com/deep_link_return"}} =
               Tool.build_deep_linking_response(request, [item])

      assert {:ok, token_claims} = verify_signature(jwt, jwk)
      assert token_claims["iss"] == "12345"
      assert token_claims["aud"] == "https://lti-ri.imsglobal.org"
      assert token_claims[ClaimKeys.key(:message_type)] == "LtiDeepLinkingResponse"
      assert token_claims[ClaimKeys.key(:data)] == "opaque-correlation"
      assert [returned_item] = token_claims[ClaimKeys.key(:content_items)]
      assert returned_item["type"] == "link"
    end

    test "supports compatibility filter strategy" do
      _jwk = jwk_fixture()

      claims =
        deep_linking_claims()
        |> put_in([ClaimKeys.key(:deep_linking_settings), "accept_types"], ["ltiResourceLink"])

      assert {:ok, request} = Tool.validate_deep_linking_request(claims)

      assert {:ok, accepted_item} =
               DeepLinking.content_item(:lti_resource_link, %{
                 "url" => "https://tool.example.com/resource/1"
               })

      assert {:ok, dropped_item} =
               DeepLinking.content_item(:link, %{"url" => "https://tool.example.com/link/1"})

      assert {:ok, %{jwt: jwt}} =
               Tool.build_deep_linking_response(request, [accepted_item, dropped_item],
                 unsupported_type_strategy: :filter_unsupported
               )

      assert {:ok, token_claims} = Joken.peek_claims(jwt)
      assert [only_item] = token_claims[ClaimKeys.key(:content_items)]
      assert only_item["type"] == "ltiResourceLink"
    end

    test "returns structured error when all items are filtered out" do
      _jwk = jwk_fixture()

      claims =
        deep_linking_claims()
        |> put_in([ClaimKeys.key(:deep_linking_settings), "accept_types"], ["ltiResourceLink"])

      assert {:ok, request} = Tool.validate_deep_linking_request(claims)

      assert {:ok, unsupported_item} =
               Tool.deep_linking_content_item(:link, %{"url" => "https://tool.example.com/link"})

      assert {:error, %{reason: :no_supported_content_items, stage: :response}} =
               Tool.build_deep_linking_response(request, [unsupported_item],
                 unsupported_type_strategy: :filter_unsupported
               )
    end
  end

  test "emits deep-linking telemetry events for request and response outcomes" do
    _jwk = jwk_fixture()

    handler_id = "tool-deep-linking-telemetry-#{System.unique_integer([:positive])}"
    parent = self()

    :ok =
      :telemetry.attach_many(
        handler_id,
        [
          [:lti_1p3, :tool, :deep_linking, :request],
          [:lti_1p3, :tool, :deep_linking, :response]
        ],
        fn event, _measurements, metadata, _config ->
          send(parent, {:telemetry_event, event, metadata})
        end,
        nil
      )

    on_exit(fn -> :telemetry.detach(handler_id) end)

    claims = deep_linking_claims()
    assert {:ok, request} = Tool.validate_deep_linking_request(claims)

    assert {:ok, item} =
             Tool.deep_linking_content_item(:link, %{"url" => "https://tool.example.com/activity"})

    assert {:ok, _payload} = Tool.build_deep_linking_response(request, [item])

    assert_receive {:telemetry_event, [:lti_1p3, :tool, :deep_linking, :request], %{result: :ok}}

    assert_receive {:telemetry_event, [:lti_1p3, :tool, :deep_linking, :response], %{result: :ok}}
  end

  defp deep_linking_claims do
    all_default_claims()
    |> Map.put(ClaimKeys.key(:message_type), "LtiDeepLinkingRequest")
    |> Map.put(
      ClaimKeys.key(:deep_linking_settings),
      %{
        "deep_link_return_url" => "https://tool.example.com/deep_link_return",
        "accept_types" => ["ltiResourceLink", "link"],
        "accept_presentation_document_targets" => ["iframe", "window"],
        "data" => "opaque-correlation"
      }
    )
  end

  defp verify_signature(jwt, jwk) do
    public_key = jwk.pem |> JOSE.JWK.from_pem() |> JOSE.JWK.to_public()
    {_kty, key_map} = JOSE.JWK.to_map(public_key)
    signer = Joken.Signer.create("RS256", key_map)

    case Joken.verify_and_validate(%{}, jwt, signer) do
      {:ok, claims} -> {:ok, claims}
      {:error, _} = error -> error
    end
  end
end
