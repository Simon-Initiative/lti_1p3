defmodule Lti_1p3.Tool.AccessToken do
  import Lti_1p3.Config

  @enforce_keys [:access_token, :token_type, :expires_in, :scope]
  defstruct [:access_token, :token_type, :expires_in, :scope]

  @type t() :: %__MODULE__{
    access_token: String.t(),
    token_type: String.t(),
    expires_in: integer(),
    scope: String.t()
  }

  require Logger

  @doc """
  Requests an OAuth2 access token. Returns {:ok, %AccessToken{}} on success, {:error, error}
  otherwise.

  As parameters, expects:
  1. The registration from which an access token is being requested
  2. A list of scopes being requested
  3. The host name of this instance of Torus
  """
  def fetch_access_token(%{auth_token_url: auth_token_url, client_id: client_id}, scopes, host) do
    client_assertion = create_client_assertion(host, %{auth_token_url: auth_token_url, client_id: client_id})
    request_token(auth_token_url, client_assertion, scopes)
  end

  defp request_token(url, client_assertion, scopes) do
    body = [
      grant_type: "client_credentials",
      client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
      client_assertion: client_assertion,
      scope: Enum.join(scopes, " ")
    ] |> URI.encode_query()

    headers = %{"Content-Type" => "application/x-www-form-urlencoded"}

    Logger.debug("Fetching access token with the following parameters")
    Logger.debug("client_assertion: #{inspect client_assertion}")
    Logger.debug("scopes #{inspect scopes}")

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.post(url, body, headers),
      {:ok, result} <- Jason.decode(body)
    do
      {:ok, %__MODULE__{
        access_token: Map.get(result, "access_token"),
        token_type: Map.get(result, "token_type"),
        expires_in: Map.get(result, "expires_in"),
        scope: Map.get(result, "scope"),
      }}
    else
      e ->
        Logger.error("Error encountered fetching access token #{inspect e}")
        {:error, "Error fetching access token"}
    end

  end

  defp create_client_assertion(host, %{auth_token_url: auth_token_url, client_id: client_id}) do
    # Get the active private key
    {:ok, active_jwk} = provider!().get_active_jwk()

    # Sign and return the JWT, include the kid of the key we are using
    # in the header.
    custom_header = %{"kid" => active_jwk.kid}
    signer = Joken.Signer.create("RS256", %{"pem" => active_jwk.pem}, custom_header)

    # define our custom claims
    custom_claims = %{
      "iss" => host,
      "aud" => auth_token_url,
      "sub" => client_id
    }
    {:ok, token, _} = Lti_1p3.JokenConfig.generate_and_sign(custom_claims, signer)

    token
  end

end
