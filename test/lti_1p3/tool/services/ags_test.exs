defmodule Lti_1p3.Tool.Services.AGSTest do
  use ExUnit.Case, async: true

  import Mox

  alias Lti_1p3.Test.MockHTTPoison
  alias Lti_1p3.Tool.Services.AccessToken
  alias Lti_1p3.Tool.Services.AGS
  alias Lti_1p3.Tool.Services.AGS.{LineItem, Score}

  @some_label "New Page"
  @query_param "type=22"

  @line_item_url "https://lms.example.edu/api/lti/courses/8/line_items/21/lineitem"
  @line_items_url "https://lms.example.edu/api/lti/courses/8/line_items"
  @lti_items_service_domain "https://registration.example.com/lti/something"

  @lti_params %{
    "aud" => "10000000000041",
    "azp" => "10000000000041",
    "email" => "test@example.edu",
    "errors" => %{"errors" => %{}},
    "exp" => 1_604_329_486,
    "family_name" => "Last",
    "given_name" => "First",
    "https://purl.imsglobal.org/spec/lti-ags/claim/endpoint" => %{
      "errors" => %{"errors" => %{}},
      "lineitems" => @line_items_url,
      "scope" => [
        "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem",
        "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem.readonly",
        "https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly",
        "https://purl.imsglobal.org/spec/lti-ags/scope/score"
      ],
      "validation_context" => nil
    },
    "https://purl.imsglobal.org/spec/lti/claim/context" => %{
      "errors" => %{"errors" => %{}},
      "id" => "07fee64bb0ab0c942859fe07b87f03ea8fefb07b",
      "label" => "Course",
      "title" => "Introduction to the Cuisine of Northern Spain",
      "type" => ["http://purl.imsglobal.org/vocab/lis/v2/course#CourseOffering"],
      "validation_context" => nil
    },
    "https://purl.imsglobal.org/spec/lti/claim/custom" => %{},
    "https://purl.imsglobal.org/spec/lti/claim/deployment_id" =>
      "77:07fee64bb0ab0c942859fe07b87f03ea8fefb07b",
    "https://purl.imsglobal.org/spec/lti/claim/launch_presentation" => %{
      "document_target" => "iframe",
      "errors" => %{"errors" => %{}},
      "height" => 400,
      "locale" => "en",
      "return_url" =>
        "https://lms.example.edu/courses/8/external_content/success/external_tool_dialog",
      "validation_context" => nil,
      "width" => 800
    },
    "https://purl.imsglobal.org/spec/lti/claim/lis" => %{
      "course_offering_sourcedid" => nil,
      "errors" => %{"errors" => %{}},
      "person_sourcedid" => nil,
      "validation_context" => nil
    },
    "https://purl.imsglobal.org/spec/lti/claim/message_type" => "LtiResourceLinkRequest",
    "https://purl.imsglobal.org/spec/lti/claim/resource_link" => %{
      "description" => nil,
      "errors" => %{"errors" => %{}},
      "id" => "07fee64bb0ab0c942859fe07b87f03ea8fefb07b",
      "title" => nil,
      "validation_context" => nil
    },
    "https://purl.imsglobal.org/spec/lti/claim/roles" => [
      "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Instructor",
      "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student",
      "http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor",
      "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner",
      "http://purl.imsglobal.org/vocab/lis/v2/system/person#User"
    ],
    "https://purl.imsglobal.org/spec/lti/claim/target_link_uri" =>
      "https://5af12c1dbcd4.ngrok.io/lti/launch",
    "https://purl.imsglobal.org/spec/lti/claim/tool_platform" => %{
      "errors" => %{"errors" => %{}},
      "guid" => "8865aa05b4b79b64a91a86042e43af5ea8ae79eb.lms.example.edu",
      "name" => "Open Learning Initiative Admin",
      "product_family_code" => "canvas",
      "validation_context" => nil,
      "version" => "cloud"
    },
    "https://purl.imsglobal.org/spec/lti/claim/version" => "1.3.0",
    "iat" => 1_604_325_886,
    "iss" => "https://lms.example.edu",
    "locale" => "en",
    "name" => "Test Person",
    "nonce" => "67d025e8-f3ca-439f-bad2-a4ef450f23a4",
    "picture" => "https://lms.example.edu/images/messages/avatar-50.png",
    "sub" => "c36c3c87-993f-4d2e-9e22-e47d5d2637ae"
  }

  test "ags" do
    assert AGS.grade_passback_enabled?(@lti_params)

    lti_ags_claim = Map.get(@lti_params, "https://purl.imsglobal.org/spec/lti-ags/claim/endpoint")

    assert AGS.has_scope?(
             lti_ags_claim,
             "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem.readonly"
           )

    refute AGS.has_scope?(
             lti_ags_claim,
             "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem.fake"
           )
  end

  describe "get_line_items_url" do
    test "returns nil if no line items claim in the params" do
      refute AGS.get_line_items_url(%{})

      refute AGS.get_line_items_url(%{}, %{
        line_items_service_domain: @lti_items_service_domain
      })
    end

    test "returns the url from line items claim when no registration present" do
      assert AGS.get_line_items_url(@lti_params) ==
        @line_items_url
    end

    test "returns the url from line items claim when registration present but not line_items_service_domain" do
      assert AGS.get_line_items_url(@lti_params, %{
        auth_server: "some auth_server"
      }) == @line_items_url

      assert AGS.get_line_items_url(@lti_params, %{
        line_items_service_domain: ""
      }) == @line_items_url

      assert AGS.get_line_items_url(@lti_params, %{
        line_items_service_domain: nil
      }) == @line_items_url
    end

    test "returns the url from line items claim with the registration line_items_service_domain" do
      assert AGS.get_line_items_url(@lti_params, %{
        line_items_service_domain: @lti_items_service_domain
      }) == "https://registration.example.com/api/lti/courses/8/line_items"
    end
  end

  describe "post_score" do
    setup [:setup_session]

    test "json in response body is returned correctly", %{
      score: score,
      line_item: line_item,
      access_token: access_token
    } do
      expect(MockHTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(%{result: "success"})}}
      end)

      {:ok, result} = AGS.post_score(score, line_item, access_token)

      assert result == "{\"result\":\"success\"}"
    end

    test "empty in response body is returned correctly", %{
      score: score,
      line_item: line_item,
      access_token: access_token
    } do
      expect(MockHTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
      end)

      {:ok, result} = AGS.post_score(score, line_item, access_token)

      assert result == ""
    end

    test "string in response body is returned correctly", %{
      score: score,
      line_item: line_item,
      access_token: access_token
    } do
      expect(MockHTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: "some string"}}
      end)

      {:ok, result} = AGS.post_score(score, line_item, access_token)

      assert result == "some string"
    end

    test "map in response body is returned correctly", %{
      score: score,
      line_item: line_item,
      access_token: access_token
    } do
      expect(MockHTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: %{key: "some string"}}}
      end)

      {:ok, result} = AGS.post_score(score, line_item, access_token)

      assert result == %{key: "some string"}
    end

    test "response with code different from 200 returns error", %{
      score: score,
      line_item: line_item,
      access_token: access_token
    } do
      expect(MockHTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{status_code: 404, body: Jason.encode!(%{result: "failure"})}}
      end)

      {:error, error} = AGS.post_score(score, line_item, access_token)

      assert error == "Error posting score"
    end

    test "scores url is build correctly without query params", %{
      score: score,
      line_item: line_item,
      access_token: access_token
    } do
      expect(MockHTTPoison, :post, fn url, _body, _headers ->
        assert "#{@line_item_url}/scores" == url

        {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
      end)

      {:ok, _response} = AGS.post_score(score, line_item, access_token)
    end
  end

  describe "headers" do
    setup [:setup_session]

    test "post score set headers correctly", %{
      score: score,
      line_item: line_item,
      access_token: access_token
    } do
      expect(MockHTTPoison, :post, fn _url, _body, headers ->
        assert [
          {"Content-Type", "application/vnd.ims.lis.v1.score+json"},
          {"Authorization", "Bearer fake_token"}
        ] == headers

        {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
      end)

      {:ok, _response} = AGS.post_score(score, line_item, access_token)
    end

    test "fetch line item set headers correctly", %{
      access_token: access_token
    } do
      expect(MockHTTPoison, :get, fn _url, headers ->
        assert [
          {"Accept", "application/vnd.ims.lis.v2.lineitemcontainer+json"},
          {"Content-Type", "application/vnd.ims.lis.v2.lineitem+json"},
          {"Authorization", "Bearer fake_token"}
        ] == headers

        {:ok, %HTTPoison.Response{status_code: 200, body: "[]"}}
      end)

      {:ok, _response} =
        AGS.fetch_line_items(
          @line_items_url,
          access_token
        )
    end

    test "create line item set headers correctly", %{
      line_item: line_item,
      access_token: access_token
    } do
      expect(MockHTTPoison, :post, fn _url, _body, headers ->
        assert [
          {"Accept", "application/vnd.ims.lis.v2.lineitemcontainer+json"},
          {"Content-Type", "application/vnd.ims.lis.v2.lineitem+json"},
          {"Authorization", "Bearer fake_token"}
        ] == headers

        {:ok, %HTTPoison.Response{status_code: 200, body: "{}"}}
      end)

      {:ok, _response} =
        AGS.create_line_item(
          @line_items_url,
          line_item.resourceId,
          100,
          @some_label,
          access_token
        )
    end

    test "update line item set headers correctly", %{
      line_item: line_item,
      access_token: access_token
    } do
      expect(MockHTTPoison, :put, fn _url, _body, headers ->
        assert [
          {"Accept", "application/vnd.ims.lis.v2.lineitemcontainer+json"},
          {"Content-Type", "application/vnd.ims.lis.v2.lineitem+json"},
          {"Authorization", "Bearer fake_token"}
        ] == headers

        {:ok, %HTTPoison.Response{status_code: 200, body: "{}"}}
      end)

      {:ok, _response} =
        AGS.update_line_item(
          line_item,
          %{},
          access_token
        )
    end

    test "fetch or create line item set headers correctly", %{
      line_item: line_item,
      access_token: access_token,
      maximum_score_provider: maximum_score_provider
    } do
      expect(MockHTTPoison, :post, fn _url, _body, headers ->
        assert [
          {"Accept", "application/vnd.ims.lis.v2.lineitemcontainer+json"},
          {"Content-Type", "application/vnd.ims.lis.v2.lineitem+json"},
          {"Authorization", "Bearer fake_token"}
        ] == headers

        {:ok, %HTTPoison.Response{status_code: 200, body: "{}"}}
      end)

      expect(MockHTTPoison, :get, fn _url, headers ->
        assert [
          {"Accept", "application/vnd.ims.lis.v2.lineitemcontainer+json"},
          {"Content-Type", "application/vnd.ims.lis.v2.lineitem+json"},
          {"Authorization", "Bearer fake_token"}
        ] == headers

        {:ok, %HTTPoison.Response{status_code: 200, body: "[]"}}
      end)

      {:ok, _response} =
        AGS.fetch_or_create_line_item(
          @line_items_url,
          line_item.resourceId,
          maximum_score_provider,
          @some_label,
          access_token
        )
    end
  end

  describe "urls generation" do
    setup [:setup_session]

    test "post score url is build correctly with query params", %{
      score: score,
      line_item_id_with_params: line_item_id_with_params,
      access_token: access_token
    } do
      expect(MockHTTPoison, :post, fn url, _body, _headers ->
        assert "#{@line_item_url}/scores?#{@query_param}" == url

        {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
      end)

      {:ok, _response} = AGS.post_score(score, line_item_id_with_params, access_token)
    end

    test "create line item url is build correctly with query params", %{
      line_item_id_with_params: line_item_id_with_params,
      access_token: access_token
    } do
      expect(MockHTTPoison, :post, fn url, _body, _headers ->
        assert line_item_id_with_params.id == url

        {:ok, %HTTPoison.Response{status_code: 200, body: "{}"}}
      end)

      {:ok, _response} =
        AGS.create_line_item(
          line_item_id_with_params.id,
          line_item_id_with_params.resourceId,
          100,
          @some_label,
          access_token
        )
    end

    test "update line item url is build correctly with query params", %{
      line_item_id_with_params: line_item_id_with_params,
      access_token: access_token
    } do
      expect(MockHTTPoison, :put, fn url, _body, _headers ->
        assert line_item_id_with_params.id == url

        {:ok, %HTTPoison.Response{status_code: 200, body: "{}"}}
      end)

      {:ok, _response} =
        AGS.update_line_item(
          line_item_id_with_params,
          %{},
          access_token
        )
    end

    test "fetch line item is build correctly with query params", %{
      access_token: access_token
    } do
      expect(MockHTTPoison, :get, fn url, _headers ->
        assert "#{@line_items_url}?#{@query_param}&limit=1000" == url

        {:ok, %HTTPoison.Response{status_code: 200, body: "[]"}}
      end)

      {:ok, _response} =
        AGS.fetch_line_items(
          "#{@line_items_url}?#{@query_param}",
          access_token
        )
    end

    test "fetch or create line item url is build correctly with query params", %{
      line_item_id_with_params: line_item_id_with_params,
      access_token: access_token,
      maximum_score_provider: maximum_score_provider
    } do
      expect(MockHTTPoison, :post, fn url, _body, _headers ->
        assert line_item_id_with_params.id == url

        {:ok, %HTTPoison.Response{status_code: 200, body: "{}"}}
      end)

      expect(MockHTTPoison, :get, fn url, _headers ->
        assert "#{line_item_id_with_params.id}&resource_id=#{line_item_id_with_params.resourceId}&limit=1" == url

        {:ok, %HTTPoison.Response{status_code: 200, body: "[]"}}
      end)

      {:ok, _response} =
        AGS.fetch_or_create_line_item(
          line_item_id_with_params.id,
          line_item_id_with_params.resourceId,
          maximum_score_provider,
          @some_label,
          access_token
        )
    end
  end

  defp setup_session(_context) do
    score = %Score{
      timestamp: "Etc/UTC" |> DateTime.now() |> elem(1),
      scoreGiven: 10,
      scoreMaximum: 10,
      comment: "comment",
      activityProgress: "activityProgress",
      gradingProgress: "gradingProgress",
      userId: "userId"
    }

    line_item = %LineItem{
      id: @line_item_url,
      scoreMaximum: 10,
      label: "label",
      resourceId: 9876
    }

    line_item_id_with_params = %LineItem{
      id: "#{@line_item_url}?#{@query_param}",
      scoreMaximum: 10,
      label: "label",
      resourceId: 9876
    }

    access_token = %AccessToken{
      scope:
        "https://purl.imsglobal.org/spec/lti-ags/scope/score https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly",
      access_token: "fake_token",
      token_type: "Bearer",
      expires_in: 3_600
    }

    maximum_score_provider = fn -> 1.0 end

    {:ok, %{
      score: score,
      line_item: line_item,
      access_token: access_token,
      line_item_id_with_params: line_item_id_with_params,
      maximum_score_provider: maximum_score_provider
    }}
  end
end
