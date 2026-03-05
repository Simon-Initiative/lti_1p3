defmodule Lti_1p3.Tool.DeepLinking.JwtSigner do
  @moduledoc """
  JWT signing helper for deep-linking responses.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Tool.DeepLinking.Errors

  @spec sign(map(), String.t()) :: {:ok, String.t()} | {:error, Errors.t()}
  def sign(claims, issuer) when is_map(claims) and is_binary(issuer) do
    with {:ok, active_jwk} <- resolve_active_jwk(),
         {:ok, jwt} <- sign_claims(claims, issuer, active_jwk) do
      {:ok, jwt}
    end
  end

  defp resolve_active_jwk do
    case provider!().get_active_jwk() do
      {:ok, active_jwk} ->
        {:ok, active_jwk}

      {:error, reason} ->
        Errors.error(
          :signing,
          :signing_key_not_available,
          "Active signing JWK is not available",
          %{
            reason: reason
          }
        )
    end
  end

  defp sign_claims(claims, issuer, active_jwk) do
    custom_header = %{"kid" => active_jwk.kid}
    signer = Joken.Signer.create("RS256", %{"pem" => active_jwk.pem}, custom_header)

    claims = Map.put(claims, "iss", issuer)

    with {:ok, claims} <- Joken.generate_claims(%{}, claims),
         {:ok, jwt, _claims} <- Joken.encode_and_sign(claims, signer) do
      {:ok, jwt}
    else
      {:error, reason} ->
        Errors.error(
          :signing,
          :response_signing_failed,
          "Unable to sign deep-linking response",
          %{
            reason: reason
          }
        )
    end
  end
end
