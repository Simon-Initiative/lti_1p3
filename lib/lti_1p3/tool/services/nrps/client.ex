defmodule Lti_1p3.Tool.Services.NRPS.Client do
  @moduledoc """
  HTTP client wrapper for NRPS page retrieval.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Services.HTTP.Request
  alias Lti_1p3.Tool.Services.AccessToken
  alias Lti_1p3.Tool.Services.NRPS.Errors
  alias Lti_1p3.Tool.Services.NRPS.Parser
  alias Lti_1p3.Tool.Services.NRPS.Telemetry

  @accept_header "application/vnd.ims.lti-nrps.v2.membershipcontainer+json"

  @spec fetch_page(String.t(), AccessToken.t(), keyword()) ::
          {:ok, Lti_1p3.Tool.Services.NRPS.MembershipPage.t()} | {:error, Errors.error_map()}
  def fetch_page(url, %AccessToken{} = access_token, opts \\ []) do
    page_index = Keyword.get(opts, :page_index, 1)
    retry_count = Keyword.get(opts, :retry_count, 0)

    Telemetry.request(%{url: url, page_index: page_index})

    do_fetch(url, access_token, page_index, retry_count)
  end

  defp do_fetch(url, %AccessToken{} = access_token, page_index, retries_left) do
    case http_client!().get(url, headers(access_token)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        with {:ok, payload} <- Jason.decode(body),
             {:ok, page} <- Parser.parse_page(payload, headers, page_index, url) do
          Telemetry.page(%{
            url: url,
            page_index: page_index,
            member_count: length(page.memberships),
            has_next: not is_nil(page.next_url)
          })

          {:ok, page}
        else
          {:error, error} ->
            Telemetry.error(Map.put(error.details, :reason, error.reason))
            {:error, error}

          parse_error ->
            error = Errors.invalid_payload(:invalid_json, %{error: inspect(parse_error)})
            Telemetry.error(Map.put(error.details, :reason, error.reason))
            {:error, error}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        retryable? = retryable_status?(status_code)

        if retryable? and retries_left > 0 do
          do_fetch(url, access_token, page_index, retries_left - 1)
        else
          error = Errors.http_error(:list_memberships, status_code, retryable?)
          Telemetry.error(Map.put(error.details, :reason, error.reason))
          {:error, error}
        end

      {:error, reason} ->
        if retries_left > 0 do
          do_fetch(url, access_token, page_index, retries_left - 1)
        else
          error = Errors.transport_error(:list_memberships, reason, true)
          Telemetry.error(Map.put(error.details, :reason, error.reason))
          {:error, error}
        end

      unexpected ->
        error = Errors.transport_error(:list_memberships, unexpected, false)
        Telemetry.error(Map.put(error.details, :reason, error.reason))
        {:error, error}
    end
  end

  defp headers(%AccessToken{} = access_token) do
    [{"Content-Type", "application/json"}]
    |> Request.with_bearer(access_token.access_token)
    |> Kernel.++([{"Accept", @accept_header}])
  end

  defp retryable_status?(status_code), do: status_code == 429 or status_code >= 500
end
