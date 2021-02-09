defmodule Lti_1p3.Test.TestHelpers do
  alias Lti_1p3.Test.Repo
  alias Lti_1p3.Test.Ecto.Lti_1p3_User

  Mox.defmock(Lti_1p3.Test.MockHTTPoison, for: HTTPoison.Base)

  def lti_1p3_user_fixture(attrs \\ %{}) do
    params =
      attrs
      |> Enum.into(%{
        sub: "a6d5c443-1f51-4783-ba1a-7686ffe3b54a",
        name: "Ms Jane Marie Doe",
        given_name: "Jane",
        family_name: "Doe",
        middle_name: "Marie",
        picture: "https://platform.example.edu/jane.jpg",
        email: "jane#{System.unique_integer([:positive])}@platform.example.edu",
        locale: "en-US",
      })

    {:ok, user} =
      Lti_1p3_User.changeset(%Lti_1p3_User{}, params)
      |> Repo.insert()

      user
  end

  def jwk_fixture(attrs \\ %{}) do
    %{private_key: private_key} = Lti_1p3.KeyGenerator.generate_key_pair()

    params =
      attrs
      |> Enum.into(%{
        pem: private_key,
        typ: "JWT",
        alg: "RS256",
        kid: UUID.uuid4(),
        active: true,
      })

    jwk = struct(Lti_1p3.Jwk, params)

    jwk
  end

  def generate_lti_stubs(args \\ %{}) do
    jwk = jwk_fixture()
    state_uuid = UUID.uuid4()
    %{
      claims: claims,
      registration_params: registration_params,
      deployment_id: deployment_id,
      kid: kid,
      state: state,
      session_state: session_state,
    } = %{
      claims: all_default_claims(),
      registration_params: %{
        issuer: "https://lti-ri.imsglobal.org",
        client_id: "12345",
        key_set_url: "some key_set_url",
        auth_token_url: "some auth_token_url",
        auth_login_url: "some auth_login_url",
        auth_server: "some auth_server",
        tool_jwk_id: jwk.id,
      },
      deployment_id: "1",
      state: state_uuid,
      session_state: state_uuid,
      kid: jwk.kid,
    } |> Map.merge(args)

    # create a signer
    signer = Joken.Signer.create("RS256", %{"pem" => jwk.pem}, %{
      "kid" => kid,
    })

    # claims
    {:ok, claims} = Joken.generate_claims(%{}, claims)
    id_token = if Map.has_key?(args, :id_token) do
      args[:id_token]
    else
      Joken.generate_and_sign!(%{}, claims, signer)
    end

    # create a registration
    registration = struct(Lti_1p3.Tool.Registration, registration_params)

    # create a deployment
    deployment = struct(Lti_1p3.Tool.Deployment, %{
      deployment_id: deployment_id,
      registration_id: registration.id
    })

    params = %{"state" => state, "id_token" => id_token}

    %{params: params, session_state: session_state, registration: registration, deployment: deployment, jwk: jwk, state_uuid: state_uuid}
  end

  def all_default_claims() do
    %{}
    |> Map.merge(security_detail_data())
    |> Map.merge(user_detail_data())
    |> Map.merge(claims_data())
    |> Map.merge(example_extension_data())
  end

  def security_detail_data() do
    %{
      "iss" => "https://lti-ri.imsglobal.org",
      "sub" => "a73d59affc5b2c4cd493",
      "aud" => "12345",
      "exp" => Timex.now |> Timex.add(Timex.Duration.from_minutes(5)) |> Timex.to_unix,
      "iat" => Timex.now |> Timex.to_unix,
      "nonce" => UUID.uuid4(),
    }
  end

  def user_detail_data() do
    %{
      "given_name" => "Chelsea",
      "family_name" => "Conroy",
      "middle_name" => "Reichel",
      "picture" => "http://example.org/Chelsea.jpg",
      "email" => "Chelsea.Conroy@example.org",
      "name" => "Chelsea Reichel Conroy",
      "locale" => "en-US",
    }
  end

  def claims_data() do
    %{
      "https://purl.imsglobal.org/spec/lti-ags/claim/endpoint" => %{
        "lineitems" => "https://lti-ri.imsglobal.org/platforms/1237/contexts/10337/line_items",
        "scope" => ["https://purl.imsglobal.org/spec/lti-ags/scope/lineitem",
        "https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly"]
      },
      "https://purl.imsglobal.org/spec/lti-ces/claim/caliper-endpoint-service" => %{
        "caliper_endpoint_url" => "https://lti-ri.imsglobal.org/platforms/1237/sensors",
        "caliper_federated_session_id" => "urn:uuid:7bec5956c5297eacf382",
        "scopes" => ["https://purl.imsglobal.org/spec/lti-ces/v1p0/scope/send"]
      },
      "https://purl.imsglobal.org/spec/lti-nrps/claim/namesroleservice" => %{
        "context_memberships_url" => "https://lti-ri.imsglobal.org/platforms/1237/contexts/10337/memberships",
        "service_versions" => ["2.0"]
      },
      "https://purl.imsglobal.org/spec/lti/claim/context" => %{
        "id" => "10337",
        "label" => "My Course",
        "title" => "My Course",
        "type" => ["Course"]
      },
      "https://purl.imsglobal.org/spec/lti/claim/custom" => %{
        "myCustomValue" => "123"
      },
      "https://purl.imsglobal.org/spec/lti/claim/deployment_id" => "1",
      "https://purl.imsglobal.org/spec/lti/claim/launch_presentation" => %{
        "document_target" => "iframe",
        "height" => 320,
        "return_url" => "https://lti-ri.imsglobal.org/platforms/1237/returns",
        "width" => 240
      },
      "https://purl.imsglobal.org/spec/lti/claim/message_type" => "LtiResourceLinkRequest",
      "https://purl.imsglobal.org/spec/lti/claim/resource_link" => %{
        "description" => "my course",
        "id" => "20052",
        "title" => "My Course"
      },
      "https://purl.imsglobal.org/spec/lti/claim/role_scope_mentor" => ["a62c52c02ba262003f5e"],
      "https://purl.imsglobal.org/spec/lti/claim/roles" => ["http://purl.imsglobal.org/vocab/lis/v2/membership#Learner",
      "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student",
      "http://purl.imsglobal.org/vocab/lis/v2/membership#Mentor"],
      "https://purl.imsglobal.org/spec/lti/claim/target_link_uri" => "https://lti-ri.imsglobal.org/lti/tools/1193/launches",
      "https://purl.imsglobal.org/spec/lti/claim/tool_platform" => %{
        "contact_email" => "",
        "description" => "",
        "guid" => 1237,
        "name" => "lti-test",
        "product_family_code" => "",
        "url" => "",
        "version" => "1.0"
      },
      "https://purl.imsglobal.org/spec/lti/claim/version" => "1.3.0",
    }
  end

  def example_extension_data() do
    %{
      "https://www.example.com/extension" => %{"color" => "violet"},
    }
  end

  def mock_get_jwk_keys(jwk) do
    body = Jason.encode!(%{
      keys: [
        jwk.pem
        |> JOSE.JWK.from_pem()
        |> JOSE.JWK.to_public()
        |> JOSE.JWK.to_map()
        |> (fn {_kty, public_jwk} -> public_jwk end).()
        |> Map.put("typ", jwk.typ)
        |> Map.put("alg", jwk.alg)
        |> Map.put("kid", jwk.kid)
        |> Map.put("use", "sig")
      ]
    })

    {:ok, %HTTPoison.Response{status_code: 200, body: body}}
  end
end

# notice: this protocol mock implementation must reside in this support directory
# because of protocol consolidation. See https://hexdocs.pm/elixir/master/Protocol.html#module-consolidation
defmodule Lti_1p3.Tool.Lti_1p3_User.Mock do
  alias Lti_1p3.Tool.Lti_1p3_User
  alias Lti_1p3.Tool.PlatformRoles
  alias Lti_1p3.Tool.ContextRoles

  defstruct [:platform_role_uris, :context_role_uris]

  defimpl Lti_1p3_User do
    def get_platform_roles(mock_user) do
      mock_user.platform_role_uris |> PlatformRoles.get_roles_by_uris()
    end

    def get_context_roles(mock_user, _context_id) do
      mock_user.context_role_uris |> ContextRoles.get_roles_by_uris()
    end
  end
end
