defmodule Lti_1p3.Utils do
  @moduledoc false
  import Lti_1p3.Config

  def registration_key_set_url(%{key_set_url: key_set_url}) do
    {:ok, key_set_url}
  end

  def extract_param(params, name) do
    case params[name] do
      nil ->
        {:error, %{reason: :missing_param, msg: "Missing #{name}"}}

      param ->
        {:ok, param}
    end
  end

  def peek_header(jwt_string) do
    case Joken.peek_header(jwt_string) do
      {:ok, header} ->
        {:ok, header}

      {:error, reason} ->
        {:error, %{reason: reason, msg: "Invalid JWT"}}
    end
  end

  def peek_claims(jwt_string) do
    case Joken.peek_claims(jwt_string) do
      {:ok, claims} ->
        {:ok, claims}

      {:error, reason} ->
        {:error, %{reason: reason, msg: "Invalid JWT"}}
    end
  end

  def peek_jwt_kid(jwt_string) do
    with {:ok, jwt_body} <- peek_header(jwt_string) do
      {:ok, jwt_body["kid"]}
    end
  end

  def validate_jwt_signature(jwt_string, key_set_url) do
    with {:ok, kid} <- peek_jwt_kid(jwt_string),
         {:ok, public_key} <- fetch_public_key(key_set_url, kid) do
      {_kty, pk} = JOSE.JWK.to_map(public_key)

      signer = Joken.Signer.create("RS256", pk)

      case Joken.verify_and_validate(%{}, jwt_string, signer) do
        {:ok, jwt} ->
          {:ok, jwt}

        {:error, reason} ->
          {:error, %{reason: reason, msg: "Invalid JWT"}}
      end
    end
  end

  def validate_timestamps(jwt) do
    try do
      case {Timex.from_unix(jwt["exp"]), Timex.from_unix(jwt["iat"])} do
        {exp, iat} ->
          # get the current time with a buffer of a few seconds to account for clock skew and rounding
          now = Timex.now()
          buffer_sec = 2
          a_few_seconds_ago = now |> Timex.subtract(Timex.Duration.from_seconds(buffer_sec))
          a_few_seconds_ahead = now |> Timex.add(Timex.Duration.from_seconds(buffer_sec))

          # check if jwt is expired and/or issued at invalid time
          case {Timex.before?(exp, a_few_seconds_ago), Timex.after?(iat, a_few_seconds_ahead)} do
            {false, false} ->
              {:ok}

            {_, false} ->
              {:error, %{reason: :invalid_jwt_timestamp, msg: "JWT exp is expired"}}

            {false, _} ->
              {:error, %{reason: :invalid_jwt_timestamp, msg: "JWT iat is invalid"}}

            _ ->
              {:error, %{reason: :invalid_jwt_timestamp, msg: "JWT exp and iat are invalid"}}
          end
      end
    rescue
      _error -> {:error, %{reason: :invalid_jwt_timestamp, msg: "Timestamps are invalid"}}
    end
  end

  def validate_nonce(jwt, domain) do
    case Lti_1p3.Nonces.create_nonce(jwt["nonce"], domain) do
      {:ok, _nonce} ->
        {:ok}

      {:error, %Lti_1p3.DataProviderError{reason: :unique_constraint_violation}} ->
        {:error, %{reason: :invalid_nonce, msg: "Duplicate nonce"}}

      {:error, %Lti_1p3.DataProviderError{msg: msg}} ->
        {:error, %{reason: :invalid_nonce, msg: msg}}
    end
  end

  def validate_issuer(jwt, issuer) do
    if jwt["iss"] == issuer do
      {:ok}
    else
      {:error,
       %{
         reason: :invalid_issuer,
         msg: "Issuer ('iss' claim) in JWT doesn't match the expected issuer"
       }}
    end
  end

  def validate_audience(jwt, audience) do
    audience_claims = String.split(jwt["aud"], ",", trim: true)

    if audience_claims in audience do
      {:ok}
    else
      {:error,
       %{
         reason: :invalid_issuer,
         msg: "Audience ('aud' claim) in JWT doesn't contain the expected audience"
       }}
    end
  end

  def fetch_public_key(key_set_url, kid) do
    public_key_set =
      case http_client!().get(key_set_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          Jason.decode!(body)

        error ->
          error
      end

    if is_container(public_key_set) do
      case Enum.find(public_key_set["keys"], fn key -> is_container(key) && key["kid"] == kid end) do
        nil ->
          return_key_not_found(kid)

        public_key_json ->
          public_key =
            public_key_json
            |> convert_map_to_base64url()
            |> JOSE.JWK.from()

          {:ok, public_key}
      end
    else
      return_key_not_found(kid)
    end
  end

  defp is_container(container) do
    Keyword.keyword?(container) || is_map(container) || is_struct(container)
  end

  defp return_key_not_found(kid) do
    {:error,
     %{
       reason: :key_not_found,
       msg: "Key with kid #{kid} not found in the fetched list of public keys"
     }}
  end

  @doc """
  Given a map representing a JWK, encodes all its values to Base64URL.
  """
  @spec convert_map_to_base64url(map()) :: map()
  def convert_map_to_base64url(key_map) do
    for {k, v} <- key_map,
        into: %{},
        do: {k, to_base64url(v)}
  end

  defp to_base64url(value) when is_binary(value) do
    case Base.decode64(value, padding: false) do
      :error -> value
      {:ok, decoded} -> Base.url_encode64(decoded, padding: false)
    end
  end

  defp to_base64url(value), do: value
end
