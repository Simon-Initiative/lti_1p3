defmodule Lti_1p3.Tool.DeepLinking do
  @moduledoc """
  Public tool deep-linking API for request validation, content item building,
  and deep-linking response generation.
  """

  alias Lti_1p3.Tool.DeepLinking.ContentItem
  alias Lti_1p3.Tool.DeepLinking.Errors
  alias Lti_1p3.Tool.DeepLinking.Request
  alias Lti_1p3.Tool.DeepLinking.RequestValidator
  alias Lti_1p3.Tool.DeepLinking.ResponseBuilder
  alias Lti_1p3.Tool.DeepLinking.Telemetry

  @type error_map :: Errors.t()

  @spec validate_request(map()) :: {:ok, Request.t()} | {:error, error_map()}
  def validate_request(claims) do
    case RequestValidator.validate_request(claims) do
      {:ok, request} = result ->
        Telemetry.emit_request(:ok, %{
          issuer: request.issuer,
          client_id: normalize_client_id(request.audience)
        })

        result

      {:error, %{reason: reason}} = result ->
        Telemetry.emit_request(:error, %{reason: reason})
        result
    end
  end

  @spec content_item(String.t() | atom(), map()) :: {:ok, ContentItem.t()} | {:error, error_map()}
  def content_item(type, attrs \\ %{}), do: ContentItem.content_item(type, attrs)

  @spec build_response(Request.t(), [ContentItem.t()], keyword()) ::
          {:ok, %{jwt: String.t(), return_url: String.t()}} | {:error, error_map()}
  def build_response(%Request{} = request, items, opts \\ []) do
    ResponseBuilder.build_response(request, items, opts)
  end

  defp normalize_client_id(aud) when is_binary(aud), do: aud
  defp normalize_client_id([head | _tail]) when is_binary(head), do: head
  defp normalize_client_id(_), do: nil
end
