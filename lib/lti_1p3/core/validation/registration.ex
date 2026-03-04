defmodule Lti_1p3.Core.Validation.Registration do
  @moduledoc """
  Registration resolution from launch claims.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Core.Errors

  @spec resolve(map()) :: {:ok, map(), map()} | {:error, Errors.t()}
  def resolve(params) do
    with {:ok, id_token} <- fetch_param(params, "id_token"),
         {:ok, claims} <- peek_claims(id_token),
         {:ok, issuer} <- required_claim(claims, "iss", :issuer),
         {:ok, client_id} <- audience_to_client_id(claims),
         {:ok, registration} <- lookup_registration(issuer, client_id) do
      {:ok, registration, claims}
    end
  end

  defp fetch_param(params, name) do
    case Map.get(params, name) do
      nil -> Errors.error(:registration, :missing_param, "Missing #{name}")
      value -> {:ok, value}
    end
  end

  defp peek_claims(jwt) do
    case Joken.peek_claims(jwt) do
      {:ok, claims} ->
        {:ok, claims}

      {:error, reason} ->
        Errors.error(:registration, :token_malformed, "Invalid JWT", %{reason: reason})
    end
  end

  defp required_claim(claims, key, name) do
    case Map.get(claims, key) do
      nil -> Errors.error(:registration, :invalid_registration, "Missing #{name} claim")
      value -> {:ok, value}
    end
  end

  defp audience_to_client_id(%{"aud" => [client_id | _]}) when is_binary(client_id),
    do: {:ok, client_id}

  defp audience_to_client_id(%{"aud" => client_id}) when is_binary(client_id),
    do: {:ok, client_id}

  defp audience_to_client_id(_claims) do
    Errors.error(:registration, :invalid_registration, "Missing or invalid aud claim")
  end

  defp lookup_registration(issuer, client_id) do
    case provider!().get_registration_by_issuer_client_id(issuer, client_id) do
      nil ->
        Errors.error(
          :registration,
          :invalid_registration,
          "Registration with issuer \"#{issuer}\" and client id \"#{client_id}\" not found",
          %{issuer: issuer, client_id: client_id}
        )

      registration ->
        {:ok, registration}
    end
  end
end
