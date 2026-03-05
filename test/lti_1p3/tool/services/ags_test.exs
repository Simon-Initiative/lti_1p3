defmodule Lti_1p3.Tool.Services.AGSTest do
  use ExUnit.Case, async: true

  import Mox

  alias Lti_1p3.Test.MockHTTPoison
  alias Lti_1p3.Tool.Services.AccessToken
  alias Lti_1p3.Tool.Services.AGS
  alias Lti_1p3.Tool.Services.AGS.Endpoint
  alias Lti_1p3.Tool.Services.AGS.Score

  @line_items_url "https://lms.example.edu/api/lti/courses/8/line_items"
  @line_item_url "https://lms.example.edu/api/lti/courses/8/line_items/21"

  @claim_map %{
    "https://purl.imsglobal.org/spec/lti-ags/claim/endpoint" => %{
      "lineitems" => @line_items_url,
      "scope" => [
        "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem",
        "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem.readonly",
        "https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly",
        "https://purl.imsglobal.org/spec/lti-ags/scope/score"
      ],
      "service_versions" => ["2.0"]
    }
  }

  setup :verify_on_exit!

  describe "from_launch_claim/1" do
    test "returns typed endpoint" do
      assert {:ok, endpoint} = AGS.from_launch_claim(@claim_map)
      assert endpoint.line_items_url == @line_items_url
      assert endpoint.service_versions == ["2.0"]
      assert "https://purl.imsglobal.org/spec/lti-ags/scope/score" in endpoint.scopes
    end

    test "returns structured error for missing claim" do
      assert {:error, %{reason: :missing_ags_claim}} = AGS.from_launch_claim(%{})
    end
  end

  describe "list_line_items/3" do
    setup [:setup_session]

    test "applies filter opts, compatibility policy, and parses page metadata", %{
      access_token: access_token
    } do
      expect(MockHTTPoison, :get, fn url, headers ->
        assert String.contains?(url, "resource_id=res-1")
        assert String.contains?(url, "limit=25")

        assert [
                 {"Accept", "application/vnd.ims.lis.v2.lineitemcontainer+json"},
                 {"Content-Type", "application/vnd.ims.lis.v2.lineitem+json"},
                 {"Authorization", "Bearer fake_token"}
               ] == headers

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [
             {"Link",
              "<https://lms.example.edu/api/lti/courses/8/line_items?page=2>; rel=\"next\""}
           ],
           body:
             Jason.encode!([
               %{
                 "id" => @line_item_url,
                 "label" => "Homework 1",
                 "scoreMaximum" => 100,
                 "resourceId" => "res-1"
               }
             ])
         }}
      end)

      assert {:ok, page} =
               AGS.list_line_items(ags_endpoint(), access_token,
                 resource_id: "res-1",
                 limit: 25,
                 compatibility: %{default_line_items_limit: 1000}
               )

      assert page.page_index == 1
      assert page.next_url == "https://lms.example.edu/api/lti/courses/8/line_items?page=2"
      assert Enum.map(page.items, & &1.label) == ["Homework 1"]
    end

    test "returns insufficient_scope for missing token scope", %{
      no_scope_access_token: access_token
    } do
      assert {:error, %{reason: :insufficient_scope, operation: :list_line_items}} =
               AGS.list_line_items(ags_endpoint(), access_token)
    end

    test "retries retryable status when configured", %{access_token: access_token} do
      expect(MockHTTPoison, :get, 2, fn _url, _headers ->
        if Process.get(:ags_retry_seen) do
          {:ok,
           %HTTPoison.Response{
             status_code: 200,
             headers: [],
             body: Jason.encode!([])
           }}
        else
          Process.put(:ags_retry_seen, true)
          {:ok, %HTTPoison.Response{status_code: 503, body: ""}}
        end
      end)

      assert {:ok, page} = AGS.list_line_items(ags_endpoint(), access_token, retry_count: 1)
      assert page.items == []
    end
  end

  describe "line item CRUD" do
    setup [:setup_session]

    test "read/create/update/delete line item operations", %{access_token: access_token} do
      expect(MockHTTPoison, :post, fn url, _body, _headers ->
        assert url == @line_items_url

        {:ok,
         %HTTPoison.Response{
           status_code: 201,
           headers: [],
           body:
             Jason.encode!(%{
               "id" => @line_item_url,
               "label" => "Homework 1",
               "scoreMaximum" => 100,
               "resourceId" => "res-1"
             })
         }}
      end)

      assert {:ok, created} =
               AGS.create_line_item(ags_endpoint(), access_token, %{
                 scoreMaximum: 100,
                 resourceId: "res-1",
                 label: "Homework 1"
               })

      assert created.id == @line_item_url

      expect(MockHTTPoison, :get, fn url, _headers ->
        assert url == @line_item_url

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [],
           body:
             Jason.encode!(%{
               "id" => @line_item_url,
               "label" => "Homework 1",
               "scoreMaximum" => 100,
               "resourceId" => "res-1"
             })
         }}
      end)

      assert {:ok, read_line_item} =
               AGS.read_line_item(@line_item_url, ags_endpoint(), access_token)

      assert read_line_item.label == "Homework 1"

      expect(MockHTTPoison, :put, fn url, _body, _headers ->
        assert url == @line_item_url

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [],
           body:
             Jason.encode!(%{
               "id" => @line_item_url,
               "label" => "Homework 1 Updated",
               "scoreMaximum" => 100,
               "resourceId" => "res-1"
             })
         }}
      end)

      assert {:ok, updated} =
               AGS.update_line_item(@line_item_url, ags_endpoint(), access_token, %{
                 scoreMaximum: 100,
                 resourceId: "res-1",
                 label: "Homework 1 Updated"
               })

      assert updated.label == "Homework 1 Updated"

      expect(MockHTTPoison, :delete, fn url, _headers ->
        assert url == @line_item_url
        {:ok, %HTTPoison.Response{status_code: 204, headers: [], body: ""}}
      end)

      assert :ok == AGS.delete_line_item(@line_item_url, ags_endpoint(), access_token)
    end
  end

  describe "score and results operations" do
    setup [:setup_session]

    test "post_score/5 validates and posts score", %{access_token: access_token, score: score} do
      expect(MockHTTPoison, :post, fn url, _body, headers ->
        assert url == "#{@line_item_url}/scores"

        assert [
                 {"Content-Type", "application/vnd.ims.lis.v1.score+json"},
                 {"Authorization", "Bearer fake_token"}
               ] == headers

        {:ok, %HTTPoison.Response{status_code: 204, body: "", headers: []}}
      end)

      assert :ok == AGS.post_score(@line_item_url, ags_endpoint(), access_token, score)
    end

    test "list_results/4 parses page and fetch_all_results/4 traverses pages", %{
      access_token: access_token
    } do
      expect(MockHTTPoison, :get, fn _url, _headers ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [
             {"Link", "<#{@line_item_url}/results?page=2>; rel=\"next\""}
           ],
           body:
             Jason.encode!([
               %{"userId" => "u-1", "resultScore" => 90.0, "resultMaximum" => 100.0}
             ])
         }}
      end)

      assert {:ok, page} = AGS.list_results(@line_item_url, ags_endpoint(), access_token)
      assert page.next_url == "#{@line_item_url}/results?page=2"
      assert Enum.map(page.items, & &1.userId) == ["u-1"]

      expect(MockHTTPoison, :get, fn url, _headers ->
        assert url == "#{@line_item_url}/results"

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [
             {"Link", "<#{@line_item_url}/results?page=2>; rel=\"next\""}
           ],
           body:
             Jason.encode!([
               %{"userId" => "u-1", "resultScore" => 90.0, "resultMaximum" => 100.0}
             ])
         }}
      end)

      expect(MockHTTPoison, :get, fn url, _headers ->
        assert url == "#{@line_item_url}/results?page=2"

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [],
           body:
             Jason.encode!([
               %{"userId" => "u-2", "resultScore" => 88.0, "resultMaximum" => 100.0}
             ])
         }}
      end)

      assert {:ok, results} = AGS.fetch_all_results(@line_item_url, ags_endpoint(), access_token)
      assert Enum.map(results, & &1.userId) == ["u-1", "u-2"]
    end
  end

  describe "telemetry" do
    setup [:setup_session]

    test "emits request/line_item/result/error/scope_denied events", %{
      access_token: access_token,
      no_scope_access_token: no_scope_access_token
    } do
      parent = self()

      handler_id = "ags-test-handler-#{System.unique_integer([:positive])}"

      :ok =
        :telemetry.attach_many(
          handler_id,
          [
            [:lti_1p3, :tool, :ags, :request],
            [:lti_1p3, :tool, :ags, :line_item],
            [:lti_1p3, :tool, :ags, :result],
            [:lti_1p3, :tool, :ags, :error],
            [:lti_1p3, :tool, :ags, :scope_denied]
          ],
          fn event, measurements, metadata, _config ->
            send(parent, {:telemetry_event, event, measurements, metadata})
          end,
          %{}
        )

      on_exit(fn -> :telemetry.detach(handler_id) end)

      expect(MockHTTPoison, :get, fn _url, _headers ->
        {:ok, %HTTPoison.Response{status_code: 500, body: "", headers: []}}
      end)

      assert {:error, %{reason: :request_failed}} =
               AGS.list_line_items(ags_endpoint(), access_token)

      assert_receive {:telemetry_event, [:lti_1p3, :tool, :ags, :request], %{count: 1}, _}
      assert_receive {:telemetry_event, [:lti_1p3, :tool, :ags, :error], %{count: 1}, _}

      expect(MockHTTPoison, :get, fn _url, _headers ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [],
           body:
             Jason.encode!([
               %{
                 "id" => @line_item_url,
                 "label" => "Homework 1",
                 "scoreMaximum" => 100,
                 "resourceId" => "res-1"
               }
             ])
         }}
      end)

      assert {:ok, _page} = AGS.list_line_items(ags_endpoint(), access_token)
      assert_receive {:telemetry_event, [:lti_1p3, :tool, :ags, :line_item], %{count: 1}, _}

      assert {:error, %{reason: :insufficient_scope}} =
               AGS.list_line_items(ags_endpoint(), no_scope_access_token)

      assert_receive {:telemetry_event, [:lti_1p3, :tool, :ags, :scope_denied], %{count: 1}, _}

      expect(MockHTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{status_code: 204, body: "", headers: []}}
      end)

      assert :ok == AGS.post_score(@line_item_url, ags_endpoint(), access_token, score_fixture())
      assert_receive {:telemetry_event, [:lti_1p3, :tool, :ags, :result], %{count: 1}, _}
    end
  end

  defp setup_session(_context) do
    {:ok,
     %{
       access_token: %AccessToken{
         scope:
           "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem https://purl.imsglobal.org/spec/lti-ags/scope/lineitem.readonly https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly https://purl.imsglobal.org/spec/lti-ags/scope/score",
         access_token: "fake_token",
         token_type: "Bearer",
         expires_in: 3600
       },
       no_scope_access_token: %AccessToken{
         scope: "https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly",
         access_token: "fake_token",
         token_type: "Bearer",
         expires_in: 3600
       },
       score: score_fixture()
     }}
  end

  defp ags_endpoint do
    %Endpoint{
      line_items_url: @line_items_url,
      line_item_url: nil,
      scopes: [
        "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem",
        "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem.readonly",
        "https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly",
        "https://purl.imsglobal.org/spec/lti-ags/scope/score"
      ],
      service_versions: ["2.0"]
    }
  end

  defp score_fixture do
    %Score{
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      scoreGiven: 10,
      scoreMaximum: 10,
      comment: "comment",
      activityProgress: "Completed",
      gradingProgress: "FullyGraded",
      userId: "userId"
    }
  end
end
