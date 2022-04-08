defmodule Lti_1p3.Tool.Services.AccessTokenTest do
  use Lti_1p3.Test.TestCase

  import Mox

  alias Lti_1p3.Test.MockHTTPoison
  alias Lti_1p3.Tool.Services.AccessToken

  # Make sure mocks are verified when the test exits
  setup [:create_active_jwk, :verify_on_exit!]

  describe "fetch_access_token/3" do
    test "returns an access_token" do
      expect(MockHTTPoison, :post, fn _url, _body, _headers -> mock_access_token() end)

      assert {:ok, %Lti_1p3.Tool.Services.AccessToken{} = token} =
               AccessToken.fetch_access_token(registration(), scopes(), "https://example.com")

      assert token.access_token == "fake_token"
      assert token.expires_in == 3_600
      assert token.token_type == "Bearer"
      assert token.scope == hd(scopes())
    end

    test "returns an error message" do
      expect(MockHTTPoison, :post, fn _url, _body, _headers -> mock_invalid_request() end)

      assert {:error, message} =
               AccessToken.fetch_access_token(registration(), scopes(), "https://example.com")

      assert message == "Error fetching access token"
    end
  end

  defp registration do
    %{
      auth_token_url: "https://example.com/auth_token_url",
      client_id: "12345"
    }
  end

  defp scopes do
    [
      "https://purl.imsglobal.org/spec/lti-ags/scope/score https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly"
    ]
  end

  defp mock_access_token do
    body =
      Jason.encode!(%{
        scope:
          "https://purl.imsglobal.org/spec/lti-ags/scope/score https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly",
        access_token: "fake_token",
        token_type: "Bearer",
        expires_in: 3_600
      })

    {:ok, %HTTPoison.Response{status_code: 200, body: body}}
  end

  defp mock_invalid_request do
    body =
      Jason.encode!(%{
        error: "invalid_scope"
      })

    {:ok, %HTTPoison.Response{status_code: 400, body: body}}
  end

  defp create_active_jwk(_context) do
    jwk = jwk_fixture()

    %{jwk: jwk}
  end
end
