defmodule Lti_1p3.Core.Validation.Jwt do
  @moduledoc """
  JWT header, algorithm, key resolution, signature, issuer, and audience validation.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Core.Errors

  @allowed_algs ["RS256"]

  @spec validate(String.t(), map(), keyword()) :: {:ok, map()} | {:error, Errors.t()}
  def validate(id_token, registration, opts \\ []) do
    allowed_algs = Keyword.get(opts, :allowed_algs, @allowed_algs)

    with {:ok, header} <- peek_header(id_token),
         :ok <- validate_algorithm(header, allowed_algs),
         {:ok, kid} <- extract_kid(header),
         {:ok, public_key} <- fetch_public_key(registration.key_set_url, kid),
         {:ok, claims} <- verify_signature(id_token, header["alg"], public_key),
         :ok <- validate_issuer(claims, registration.issuer),
         :ok <- validate_audience(claims, registration.client_id) do
      {:ok, claims}
    end
  end

  defp peek_header(jwt) do
    case Joken.peek_header(jwt) do
      {:ok, header} -> {:ok, header}
      {:error, reason} -> Errors.error(:jwt, :token_malformed, "Invalid JWT", %{reason: reason})
    end
  end

  defp validate_algorithm(%{"alg" => alg}, allowed_algs) do
    if alg in allowed_algs do
      :ok
    else
      Errors.error(:jwt, :invalid_jwt_alg, "Unsupported JWT alg #{inspect(alg)}")
    end
  end

  defp validate_algorithm(_header, _allowed_algs) do
    Errors.error(:jwt, :missing_jwt_alg, "JWT header is missing alg")
  end

  defp extract_kid(%{"kid" => kid}) when is_binary(kid) and kid != "", do: {:ok, kid}
  defp extract_kid(_header), do: Errors.error(:jwt, :missing_kid, "JWT header is missing kid")

  defp fetch_public_key(key_set_url, kid) do
    case key_provider!().get_public_key(key_set_url, kid) do
      {:ok, key} ->
        {:ok, key}

      {:error, %{reason: reason, msg: msg}} ->
        Errors.error(:jwt, reason, msg)

      {:error, reason} ->
        Errors.error(:jwt, :key_resolution_failed, "Failed to resolve key", %{reason: reason})
    end
  end

  defp verify_signature(id_token, alg, public_key) do
    {_kty, key_map} = JOSE.JWK.to_map(public_key)
    signer = Joken.Signer.create(alg, key_map)

    case Joken.verify_and_validate(%{}, id_token, signer) do
      {:ok, claims} -> {:ok, claims}
      {:error, reason} -> Errors.error(:jwt, :signature_error, "Invalid JWT", %{reason: reason})
    end
  end

  defp validate_issuer(%{"iss" => issuer}, issuer), do: :ok

  defp validate_issuer(_claims, _issuer) do
    Errors.error(
      :jwt,
      :invalid_issuer,
      "Issuer ('iss' claim) in JWT doesn't match the expected issuer"
    )
  end

  defp validate_audience(%{"aud" => audience}, expected_client_id) when is_binary(audience) do
    if audience == expected_client_id do
      :ok
    else
      Errors.error(
        :jwt,
        :invalid_audience,
        "Audience ('aud' claim) in JWT doesn't contain the expected audience"
      )
    end
  end

  defp validate_audience(%{"aud" => audiences} = claims, expected_client_id)
       when is_list(audiences) do
    cond do
      length(audiences) == 1 and expected_client_id in audiences ->
        :ok

      length(audiences) > 1 and expected_client_id in audiences and
          Map.get(claims, "azp") == expected_client_id ->
        :ok

      true ->
        Errors.error(
          :jwt,
          :invalid_audience,
          "Audience ('aud' claim) in JWT doesn't contain the expected audience"
        )
    end
  end

  defp validate_audience(_claims, _expected_client_id) do
    Errors.error(:jwt, :invalid_audience, "Audience ('aud' claim) in JWT is malformed")
  end
end
