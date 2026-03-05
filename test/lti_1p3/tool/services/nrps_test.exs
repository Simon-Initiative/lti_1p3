defmodule Lti_1p3.Tool.Services.NRPSTest do
  use ExUnit.Case, async: true

  import Mox

  alias Lti_1p3.Test.MockHTTPoison
  alias Lti_1p3.Tool.Services.AccessToken
  alias Lti_1p3.Tool.Services.NRPS
  alias Lti_1p3.Tool.Services.NRPS.Endpoint

  @context_memberships_url "https://lms.example.edu/api/lti/courses/8/names_and_roles"

  @lti_params %{
    "https://purl.imsglobal.org/spec/lti-nrps/claim/namesroleservice" => %{
      "context_memberships_url" => @context_memberships_url,
      "service_versions" => ["2.0"],
      "scope" => [
        "https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly"
      ]
    }
  }

  setup :verify_on_exit!

  describe "from_launch_claim/1" do
    test "returns typed endpoint" do
      assert {:ok, endpoint} = NRPS.from_launch_claim(@lti_params)
      assert endpoint.context_memberships_url == @context_memberships_url
      assert endpoint.service_versions == ["2.0"]
      assert endpoint.scopes == NRPS.required_scopes()
    end

    test "returns structured error for missing claim" do
      assert {:error, %{reason: :missing_nrps_claim}} = NRPS.from_launch_claim(%{})
    end
  end

  describe "list_memberships/3" do
    setup [:setup_session]

    test "applies filter opts and parses page metadata", %{access_token: access_token} do
      expect(MockHTTPoison, :get, fn url, headers ->
        assert url ==
                 "#{@context_memberships_url}?limit=25&role=Instructor&status=Active"

        assert [
                 {"Content-Type", "application/json"},
                 {"Authorization", "Bearer fake_token"},
                 {"Accept", "application/vnd.ims.lti-nrps.v2.membershipcontainer+json"}
               ] == headers

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [
             {"Link",
              "<https://lms.example.edu/api/lti/courses/8/names_and_roles?page=2>; rel=\"next\""}
           ],
           body:
             Jason.encode!(%{
               "members" => [
                 %{
                   "status" => "Active",
                   "name" => "Test Person",
                   "picture" => nil,
                   "given_name" => "Test",
                   "middle_name" => nil,
                   "family_name" => "Person",
                   "email" => "test@example.edu",
                   "user_id" => "u-1",
                   "roles" => [
                     "http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor"
                   ]
                 }
               ]
             })
         }}
      end)

      assert {:ok, page} =
               NRPS.list_memberships(nrps_endpoint(), access_token,
                 limit: 25,
                 role: "Instructor",
                 status: "Active"
               )

      assert page.page_index == 1
      assert page.next_url == "https://lms.example.edu/api/lti/courses/8/names_and_roles?page=2"
      assert Enum.map(page.memberships, & &1.roles) == [["instructor"]]
    end

    test "returns insufficient_scope for missing scope", %{no_scope_access_token: access_token} do
      assert {:error, %{reason: :insufficient_scope}} =
               NRPS.list_memberships(nrps_endpoint(), access_token)
    end

    test "retries retryable errors when retry_count is configured", %{access_token: access_token} do
      expect(MockHTTPoison, :get, 2, fn _url, _headers ->
        if Process.get(:nrps_retry_seen) do
          {:ok,
           %HTTPoison.Response{
             status_code: 200,
             headers: [],
             body: Jason.encode!(%{"members" => []})
           }}
        else
          Process.put(:nrps_retry_seen, true)
          {:ok, %HTTPoison.Response{status_code: 503, body: ""}}
        end
      end)

      assert {:ok, page} = NRPS.list_memberships(nrps_endpoint(), access_token, retry_count: 1)
      assert page.memberships == []
    end
  end

  describe "fetch_all_memberships/3" do
    setup [:setup_session]

    test "traverses multiple pages", %{access_token: access_token} do
      expect(MockHTTPoison, :get, fn url, _headers ->
        assert url == @context_memberships_url

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [
             {"Link",
              "<https://lms.example.edu/api/lti/courses/8/names_and_roles?page=2>; rel=\"next\""}
           ],
           body: Jason.encode!(%{"members" => [member("u-1", "Instructor")]})
         }}
      end)

      expect(MockHTTPoison, :get, fn url, _headers ->
        assert url == "https://lms.example.edu/api/lti/courses/8/names_and_roles?page=2"

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [],
           body: Jason.encode!(%{"members" => [member("u-2", "Learner")]})
         }}
      end)

      assert {:ok, memberships} = NRPS.fetch_all_memberships(nrps_endpoint(), access_token)
      assert Enum.map(memberships, & &1.user_id) == ["u-1", "u-2"]
    end

    test "enforces max_pages guard", %{access_token: access_token} do
      expect(MockHTTPoison, :get, fn _url, _headers ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [
             {"Link",
              "<https://lms.example.edu/api/lti/courses/8/names_and_roles?page=2>; rel=\"next\""}
           ],
           body: Jason.encode!(%{"members" => [member("u-1", "Instructor")]})
         }}
      end)

      assert {:error, %{reason: :max_pages_exceeded}} =
               NRPS.fetch_all_memberships(nrps_endpoint(), access_token, max_pages: 1)
    end
  end

  describe "stream_memberships/3" do
    setup [:setup_session]

    test "streams members across pages", %{access_token: access_token} do
      expect(MockHTTPoison, :get, fn _url, _headers ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [
             {"Link",
              "<https://lms.example.edu/api/lti/courses/8/names_and_roles?page=2>; rel=\"next\""}
           ],
           body: Jason.encode!(%{"members" => [member("u-1", "Instructor")]})
         }}
      end)

      expect(MockHTTPoison, :get, fn _url, _headers ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [],
           body: Jason.encode!(%{"members" => [member("u-2", "Learner")]})
         }}
      end)

      results = NRPS.stream_memberships(nrps_endpoint(), access_token) |> Enum.to_list()

      assert Enum.map(results, & &1.user_id) == ["u-1", "u-2"]
    end
  end

  describe "telemetry" do
    setup [:setup_session]

    test "emits request/page/error telemetry events", %{access_token: access_token} do
      parent = self()

      handler_id = "nrps-test-handler-#{System.unique_integer([:positive])}"

      :ok =
        :telemetry.attach_many(
          handler_id,
          [
            [:lti_1p3, :tool, :nrps, :request],
            [:lti_1p3, :tool, :nrps, :page],
            [:lti_1p3, :tool, :nrps, :membership],
            [:lti_1p3, :tool, :nrps, :error]
          ],
          fn event, measurements, metadata, _config ->
            send(parent, {:telemetry_event, event, measurements, metadata})
          end,
          %{}
        )

      on_exit(fn -> :telemetry.detach(handler_id) end)

      expect(MockHTTPoison, :get, fn _url, _headers ->
        {:ok, %HTTPoison.Response{status_code: 500, body: ""}}
      end)

      assert {:error, %{reason: :request_failed}} =
               NRPS.list_memberships(nrps_endpoint(), access_token)

      assert_receive {:telemetry_event, [:lti_1p3, :tool, :nrps, :request], %{count: 1}, _}
      assert_receive {:telemetry_event, [:lti_1p3, :tool, :nrps, :error], %{count: 1}, _}

      expect(MockHTTPoison, :get, fn _url, _headers ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [],
           body: Jason.encode!(%{"members" => [member("u-1", "Instructor")]})
         }}
      end)

      assert {:ok, _} = NRPS.list_memberships(nrps_endpoint(), access_token)

      assert_receive {:telemetry_event, [:lti_1p3, :tool, :nrps, :page], %{count: 1}, _}

      assert_receive {:telemetry_event, [:lti_1p3, :tool, :nrps, :membership], %{count: 1}, _}
    end
  end

  describe "legacy fetch_memberships/2" do
    setup [:setup_session]

    test "returns string error tuple shape on failure", %{access_token: access_token} do
      expect(MockHTTPoison, :get, fn _url, _headers ->
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      assert {:error, "Error retrieving memberships"} =
               apply(NRPS, :fetch_memberships, [@context_memberships_url, access_token])
    end
  end

  defp nrps_endpoint do
    %Endpoint{
      context_memberships_url: @context_memberships_url,
      scopes: NRPS.required_scopes(),
      service_versions: ["2.0"]
    }
  end

  defp setup_session(_context) do
    access_token = %AccessToken{
      scope:
        "https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly https://purl.imsglobal.org/spec/lti-ags/scope/score",
      access_token: "fake_token",
      token_type: "Bearer",
      expires_in: 3_600
    }

    no_scope_access_token = %AccessToken{
      scope: "https://purl.imsglobal.org/spec/lti-ags/scope/score",
      access_token: "fake_token",
      token_type: "Bearer",
      expires_in: 3_600
    }

    {:ok, %{access_token: access_token, no_scope_access_token: no_scope_access_token}}
  end

  defp member(user_id, role) do
    %{
      "status" => "Active",
      "name" => "Test Person",
      "picture" => nil,
      "given_name" => "Test",
      "middle_name" => nil,
      "family_name" => "Person",
      "email" => "test@example.edu",
      "user_id" => user_id,
      "roles" => ["http://purl.imsglobal.org/vocab/lis/v2/membership##{role}"]
    }
  end
end
