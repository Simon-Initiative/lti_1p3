defmodule Lti_1p3.Tool.DeepLinking.ResponseBuilder do
  @moduledoc """
  Builds and signs `LtiDeepLinkingResponse` JWT payloads.
  """

  alias Lti_1p3.DeepLinking.ClaimKeys
  alias Lti_1p3.Tool.DeepLinking.CompatibilityPolicy
  alias Lti_1p3.Tool.DeepLinking.ContentItem
  alias Lti_1p3.Tool.DeepLinking.Errors
  alias Lti_1p3.Tool.DeepLinking.JwtSigner
  alias Lti_1p3.Tool.DeepLinking.Request
  alias Lti_1p3.Tool.DeepLinking.Telemetry

  def build_response(request, items, opts \\ [])

  @spec build_response(Request.t(), [ContentItem.t()], keyword()) ::
          {:ok, %{jwt: String.t(), return_url: String.t()}} | {:error, Errors.t()}
  def build_response(%Request{} = request, items, opts) when is_list(items) do
    with {:ok, claim_items} <- to_claim_items(items),
         {:ok, filtered_items} <-
           CompatibilityPolicy.apply(claim_items, request.settings.accept_types, opts),
         {:ok, claims} <- build_claims(request, filtered_items),
         {:ok, jwt} <- JwtSigner.sign(claims, request.audience |> normalize_issuer()) do
      Telemetry.emit_response(:ok, %{
        issuer: request.issuer,
        client_id: normalize_client_id(request.audience),
        item_count: length(filtered_items)
      })

      {:ok, %{jwt: jwt, return_url: request.settings.deep_link_return_url}}
    else
      {:error, %{reason: reason} = error} ->
        Telemetry.emit_response(:error, %{
          issuer: request.issuer,
          client_id: normalize_client_id(request.audience),
          reason: reason,
          item_count: length(items)
        })

        {:error, error}
    end
  end

  def build_response(_request, _items, _opts) do
    Errors.error(
      :response,
      :invalid_deep_linking_request,
      "Request must be a DeepLinking request"
    )
  end

  defp to_claim_items(items) do
    if Enum.all?(items, &match?(%ContentItem{}, &1)) do
      {:ok, Enum.map(items, &ContentItem.to_claim/1)}
    else
      Errors.error(
        :response,
        :invalid_content_items,
        "Content items must be built with Lti_1p3.Tool.DeepLinking.ContentItem"
      )
    end
  end

  defp build_claims(%Request{} = request, claim_items) do
    claims = %{
      "aud" => request.issuer,
      ClaimKeys.key(:message_type) => "LtiDeepLinkingResponse",
      ClaimKeys.key(:version) => "1.3.0",
      ClaimKeys.key(:content_items) => claim_items,
      "nonce" => request.nonce
    }

    claims = maybe_put_data(claims, request)

    {:ok, claims}
  end

  defp maybe_put_data(claims, %Request{settings: %{data: nil}}), do: claims

  defp maybe_put_data(claims, %Request{settings: %{data: data}}) do
    Map.put(claims, ClaimKeys.key(:data), data)
  end

  # Tool deep-link responses use client_id as issuer.
  defp normalize_issuer(aud) when is_binary(aud), do: aud
  defp normalize_issuer([head | _tail]) when is_binary(head), do: head

  defp normalize_client_id(aud) when is_binary(aud), do: aud
  defp normalize_client_id([head | _tail]) when is_binary(head), do: head
  defp normalize_client_id(_), do: nil
end
