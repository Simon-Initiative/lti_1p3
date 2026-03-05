defmodule Lti_1p3.Tool.Services.AGS.Client do
  @moduledoc """
  HTTP client wrapper for AGS operations.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Services.HTTP.Request
  alias Lti_1p3.Tool.Services.AccessToken
  alias Lti_1p3.Tool.Services.AGS.Errors
  alias Lti_1p3.Tool.Services.AGS.Telemetry

  @spec request(atom(), :get | :post | :put | :delete, String.t(), AccessToken.t(), keyword()) ::
          {:ok,
           %{status_code: non_neg_integer(), body: term(), headers: [{String.t(), String.t()}]}}
          | {:error, Errors.error_map()}
  def request(operation, method, url, %AccessToken{} = access_token, opts \\ []) do
    retry_count = Keyword.get(opts, :retry_count, 0)

    Telemetry.request(%{operation: operation, method: method, url: redact_url(url)})

    do_request(operation, method, url, access_token, opts, retry_count)
  end

  defp do_request(operation, method, url, %AccessToken{} = access_token, opts, retries_left) do
    body = Keyword.get(opts, :body, "")

    headers =
      opts
      |> Keyword.get(:headers, [])
      |> Request.with_bearer(access_token.access_token)

    case dispatch(method, url, body, headers) do
      {:ok,
       %HTTPoison.Response{
         status_code: status_code,
         body: response_body,
         headers: response_headers
       }} ->
        expected_statuses = Keyword.get(opts, :expected_statuses, [200])
        retryable? = retryable_status?(status_code)

        if status_code in expected_statuses do
          {:ok, %{status_code: status_code, body: response_body, headers: response_headers || []}}
        else
          maybe_retry_or_error(
            operation,
            method,
            url,
            access_token,
            opts,
            retries_left,
            retryable?,
            fn ->
              Errors.request_failed(operation, status_code, retryable?)
            end
          )
        end

      {:error, reason} ->
        maybe_retry_or_error(operation, method, url, access_token, opts, retries_left, true, fn ->
          Errors.transport_error(operation, reason, true)
        end)

      unexpected ->
        error = Errors.transport_error(operation, unexpected, false)
        Telemetry.error(Map.put(error, :url, redact_url(url)))
        {:error, error}
    end
  end

  defp maybe_retry_or_error(
         operation,
         method,
         url,
         access_token,
         opts,
         retries_left,
         retryable?,
         error_builder
       ) do
    if retryable? and retries_left > 0 do
      do_request(operation, method, url, access_token, opts, retries_left - 1)
    else
      error = error_builder.()
      Telemetry.error(Map.put(error, :url, redact_url(url)))
      {:error, error}
    end
  end

  defp dispatch(:get, url, _body, headers), do: http_client!().get(url, headers)
  defp dispatch(:delete, url, _body, headers), do: http_client!().delete(url, headers)
  defp dispatch(:post, url, body, headers), do: http_client!().post(url, body, headers)
  defp dispatch(:put, url, body, headers), do: http_client!().put(url, body, headers)

  defp retryable_status?(status_code), do: status_code == 429 or status_code >= 500

  defp redact_url(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host, path: path} when is_binary(scheme) and is_binary(host) ->
        URI.to_string(%URI{scheme: scheme, host: host, path: path})

      _ ->
        "invalid_url"
    end
  end
end
