defmodule Lti_1p3.Tool.Services.NRPS do
  @moduledoc """
  Implementation of LTI Names and Roles Provisioning Service (NRPS) version 2.0.

  For information on the standard, see:
  https://www.imsglobal.org/spec/lti-nrps/v2p0
  """

  alias Lti_1p3.Services.HTTP.QueryFilters
  alias Lti_1p3.Tool.Services.AccessToken
  alias Lti_1p3.Tool.Services.NRPS.Client
  alias Lti_1p3.Tool.Services.NRPS.Endpoint
  alias Lti_1p3.Tool.Services.NRPS.Errors
  alias Lti_1p3.Tool.Services.NRPS.Membership
  alias Lti_1p3.Tool.Services.NRPS.MembershipPage
  alias Lti_1p3.Tool.Services.NRPS.Parser
  alias Lti_1p3.Tool.Services.NRPS.ScopePolicy

  @lti_nrps_claim_url "https://purl.imsglobal.org/spec/lti-nrps/claim/namesroleservice"
  @context_memberships_url_key "context_memberships_url"

  @type error_map :: Errors.error_map()

  @doc """
  Parses a launch claim map into a typed NRPS endpoint.
  """
  @spec from_launch_claim(map()) :: {:ok, Endpoint.t()} | {:error, error_map()}
  def from_launch_claim(claim_map), do: Parser.parse_endpoint(claim_map)

  @doc """
  Lists a single memberships page.

  Supported options:
  - `:role`, `:status`, `:resource_link_id`, `:limit`
  - `:retry_count` (default `0`)
  - `:page_index` (internal use)
  """
  @spec list_memberships(Endpoint.t(), AccessToken.t(), keyword()) ::
          {:ok, MembershipPage.t()} | {:error, error_map()}
  def list_memberships(%Endpoint{} = endpoint, %AccessToken{} = access_token, opts \\ []) do
    with :ok <- ScopePolicy.preflight(endpoint, access_token),
         {:ok, request_url} <- build_request_url(endpoint.context_memberships_url, opts),
         {:ok, page} <-
           Client.fetch_page(request_url, access_token,
             retry_count: Keyword.get(opts, :retry_count, 0),
             page_index: Keyword.get(opts, :page_index, 1)
           ) do
      {:ok, page}
    end
  end

  @doc """
  Streams memberships across pages.

  Stream items are `%Membership{}` on success. If a request fails during traversal,
  the stream emits a single `{:error, error_map}` item and halts.
  """
  @spec stream_memberships(Endpoint.t(), AccessToken.t(), keyword()) :: Enumerable.t()
  def stream_memberships(%Endpoint{} = endpoint, %AccessToken{} = access_token, opts \\ []) do
    Stream.resource(
      fn -> {:next, endpoint.context_memberships_url, 1, true} end,
      fn
        {:done, _url, _page_index, _first_page?} ->
          {:halt, :done}

        {:next, url, page_index, first_page?} ->
          request_opts =
            if first_page? do
              opts |> Keyword.put(:page_index, page_index)
            else
              opts
              |> Keyword.drop([:role, :status, :resource_link_id, :limit])
              |> Keyword.put(:page_index, page_index)
            end

          endpoint_for_request =
            if first_page? do
              endpoint
            else
              %Endpoint{endpoint | context_memberships_url: url}
            end

          case list_memberships(endpoint_for_request, access_token, request_opts) do
            {:ok, %MembershipPage{} = page} ->
              next_state =
                if page.next_url do
                  {:next, page.next_url, page_index + 1, false}
                else
                  {:done, url, page_index, false}
                end

              {page.memberships, next_state}

            {:error, error} ->
              {[{:error, error}], {:done, url, page_index, false}}
          end
      end,
      fn _ -> :ok end
    )
  end

  @doc """
  Fetches all memberships across pages with a max-page guard.

  Supported options:
  - `:max_pages` (default `100`)
  - `:retry_count` (default `0`)
  - `:role`, `:status`, `:resource_link_id`, `:limit` (applies to first request)
  """
  @spec fetch_all_memberships(Endpoint.t(), AccessToken.t(), keyword()) ::
          {:ok, [Membership.t()]} | {:error, error_map()}
  def fetch_all_memberships(%Endpoint{} = endpoint, %AccessToken{} = access_token, opts \\ []) do
    max_pages = Keyword.get(opts, :max_pages, 100)

    do_fetch_all(endpoint, access_token, opts, 1, max_pages, [])
  end

  @doc """
  Backward-compatible single-call helper that returns memberships only.

  This keeps the historical `{:ok, memberships} | {:error, "Error retrieving memberships"}`
  return shape.
  """
  @deprecated "Use from_launch_claim/1 with list_memberships/3, stream_memberships/3, or fetch_all_memberships/3."
  @spec fetch_memberships(String.t(), AccessToken.t()) ::
          {:ok, [Membership.t()]} | {:error, String.t()}
  def fetch_memberships(context_memberships_url, %AccessToken{} = access_token) do
    endpoint = %Endpoint{
      context_memberships_url: context_memberships_url,
      scopes: required_scopes(),
      service_versions: ["2.0"]
    }

    case list_memberships(endpoint, access_token, limit: 1000) do
      {:ok, %MembershipPage{memberships: memberships}} -> {:ok, memberships}
      {:error, _error} -> {:error, "Error retrieving memberships"}
    end
  end

  @doc """
  Returns true if NRPS is enabled in launch params (claim present + URL available).
  """
  @spec nrps_enabled?(map()) :: boolean()
  def nrps_enabled?(lti_launch_params) do
    case Map.get(lti_launch_params, @lti_nrps_claim_url) do
      nil -> false
      config -> Map.has_key?(config, @context_memberships_url_key)
    end
  end

  @doc """
  Returns the required scopes for NRPS operations.
  """
  @spec required_scopes() :: [String.t()]
  def required_scopes, do: [ScopePolicy.required_scope()]

  @doc """
  Returns the context memberships URL from launch claims or `nil`.
  """
  @spec get_context_memberships_url(map()) :: String.t() | nil
  def get_context_memberships_url(lti_launch_params) do
    Map.get(lti_launch_params, @lti_nrps_claim_url, %{})
    |> Map.get(@context_memberships_url_key)
  end

  defp do_fetch_all(_endpoint, _access_token, _opts, page_index, max_pages, _acc)
       when page_index > max_pages do
    {:error, Errors.max_pages_exceeded(max_pages)}
  end

  defp do_fetch_all(endpoint, access_token, opts, page_index, max_pages, acc) do
    request_opts = Keyword.put(opts, :page_index, page_index)

    with {:ok, %MembershipPage{} = page} <- list_memberships(endpoint, access_token, request_opts) do
      merged = acc ++ page.memberships

      if page.next_url do
        do_fetch_all(
          %Endpoint{endpoint | context_memberships_url: page.next_url},
          access_token,
          drop_filter_opts(opts),
          page_index + 1,
          max_pages,
          merged
        )
      else
        {:ok, merged}
      end
    end
  end

  defp build_request_url(base_url, opts) do
    filters =
      opts
      |> Keyword.take([:role, :status, :resource_link_id, :limit])

    with {:ok, normalized_filters} <- QueryFilters.normalize(filters) do
      {:ok, QueryFilters.append_to_url(base_url, normalized_filters)}
    else
      {:error, reason} -> {:error, Errors.invalid_filter(reason)}
    end
  end

  defp drop_filter_opts(opts), do: Keyword.drop(opts, [:role, :status, :resource_link_id, :limit])
end
