defmodule Lti_1p3.Platform.Services.AGSTest do
  use Lti_1p3.Test.TestCase

  alias Lti_1p3.Platform.Services.AGS
  alias Lti_1p3.Platform.Services.AGS.Score

  @deployment_id "deployment-1"
  @context_id "context-1"
  @line_item_id "line-item-1"

  @all_scopes [
    "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem",
    "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem.readonly",
    "https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly",
    "https://purl.imsglobal.org/spec/lti-ags/scope/score"
  ]

  @deployment_claim_key "https://purl.imsglobal.org/spec/lti/claim/deployment_id"
  @context_claim_key "https://purl.imsglobal.org/spec/lti/claim/context"

  describe "authorize_operation/3" do
    test "authorizes valid scope, deployment, and context" do
      assert :ok = AGS.authorize_operation(context().claims, :list_line_items, context())
    end

    test "returns insufficient_scope for missing scope" do
      no_scope_context =
        context(["https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly"])

      assert {:error, %{reason: :insufficient_scope}} =
               AGS.authorize_operation(
                 no_scope_context.claims,
                 :list_line_items,
                 no_scope_context
               )
    end

    test "returns invalid_context for context mismatch" do
      bad_claims =
        context().claims
        |> Map.put(@context_claim_key, %{"id" => "other-context"})

      assert {:error, %{reason: :invalid_context}} =
               AGS.authorize_operation(bad_claims, :list_line_items, context())
    end
  end

  describe "line item, score, and result operations" do
    test "executes line item CRUD and score/results flows" do
      assert {:ok, created} =
               AGS.create_line_item(context(), %{
                 id: @line_item_id,
                 scoreMaximum: 100,
                 label: "Homework 1",
                 resourceId: "res-1",
                 tag: "hw"
               })

      assert created.id == @line_item_id

      assert {:ok, page} = AGS.list_line_items(context(), resource_id: "res-1", limit: 10)
      assert Enum.map(page.items, & &1.id) == [@line_item_id]

      assert {:ok, line_item} = AGS.read_line_item(context(), @line_item_id)
      assert line_item.label == "Homework 1"

      assert {:ok, updated} =
               AGS.update_line_item(context(), @line_item_id, %{
                 scoreMaximum: 100,
                 label: "Homework 1 Updated",
                 resourceId: "res-1"
               })

      assert updated.label == "Homework 1 Updated"

      assert :ok =
               AGS.post_score(context(), @line_item_id, %Score{
                 timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
                 scoreGiven: 95,
                 scoreMaximum: 100,
                 comment: "Great work",
                 activityProgress: "Completed",
                 gradingProgress: "FullyGraded",
                 userId: "student-1"
               })

      assert {:ok, results_page} =
               AGS.list_results(context(), @line_item_id, user_id: "student-1")

      assert Enum.map(results_page.items, & &1.userId) == ["student-1"]

      assert :ok = AGS.delete_line_item(context(), @line_item_id)
      assert {:error, %{reason: :not_found}} = AGS.read_line_item(context(), @line_item_id)
    end
  end

  describe "telemetry" do
    test "emits request/denied/error and operation events" do
      parent = self()
      handler_id = "platform-ags-test-handler-#{System.unique_integer([:positive])}"

      :ok =
        :telemetry.attach_many(
          handler_id,
          [
            [:lti_1p3, :platform, :ags, :request],
            [:lti_1p3, :platform, :ags, :denied],
            [:lti_1p3, :platform, :ags, :error],
            [:lti_1p3, :platform, :ags, :line_item],
            [:lti_1p3, :platform, :ags, :score],
            [:lti_1p3, :platform, :ags, :result]
          ],
          fn event, measurements, metadata, _config ->
            send(parent, {:telemetry_event, event, measurements, metadata})
          end,
          %{}
        )

      on_exit(fn -> :telemetry.detach(handler_id) end)

      assert {:ok, _line_item} =
               AGS.create_line_item(context(), %{
                 id: @line_item_id,
                 scoreMaximum: 100,
                 label: "Telemetry Item",
                 resourceId: "res-1"
               })

      assert_receive {:telemetry_event, [:lti_1p3, :platform, :ags, :request], %{count: 1}, _}
      assert_receive {:telemetry_event, [:lti_1p3, :platform, :ags, :line_item], %{count: 1}, _}

      assert :ok =
               AGS.post_score(context(), @line_item_id, %{
                 timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
                 scoreGiven: 80,
                 activityProgress: "Completed",
                 gradingProgress: "FullyGraded",
                 userId: "student-2"
               })

      assert_receive {:telemetry_event, [:lti_1p3, :platform, :ags, :score], %{count: 1}, _}

      assert {:ok, _results} = AGS.list_results(context(), @line_item_id)
      assert_receive {:telemetry_event, [:lti_1p3, :platform, :ags, :result], %{count: 1}, _}

      no_scope_context =
        context(["https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly"])

      assert {:error, %{reason: :insufficient_scope}} =
               AGS.create_line_item(no_scope_context, %{})

      assert_receive {:telemetry_event, [:lti_1p3, :platform, :ags, :denied], %{count: 1}, _}

      assert {:error, %{reason: :not_found}} = AGS.read_line_item(context(), "unknown")
      assert_receive {:telemetry_event, [:lti_1p3, :platform, :ags, :error], %{count: 1}, _}
    end
  end

  defp context(scopes \\ @all_scopes) do
    scope_string = Enum.join(scopes, " ")

    claims = %{
      "scope" => scope_string,
      @deployment_claim_key => @deployment_id,
      @context_claim_key => %{"id" => @context_id}
    }

    %{
      deployment_id: @deployment_id,
      context_id: @context_id,
      scopes: scopes,
      claims: claims
    }
  end
end
