defmodule Lti_1p3.Tool.Services.AGSTest do
  use ExUnit.Case, async: true

  alias Lti_1p3.Tool.Services.AGS

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
      "lineitems" => "https://lms.example.edu/api/lti/courses/8/line_items",
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
      refute AGS.get_line_items_url(%{}, %{})
    end

    test "returns the url from line items claim when no registration present" do
      assert AGS.get_line_items_url(@lti_params) ==
        "https://lms.example.edu/api/lti/courses/8/line_items"
    end

    test "returns the url from line items claim with the registration auth server domain" do
      assert AGS.get_line_items_url(@lti_params, %{
        auth_server: "https://registration.example.com/lti/something"
      }) == "https://registration.example.com/api/lti/courses/8/line_items"
    end
  end
end
