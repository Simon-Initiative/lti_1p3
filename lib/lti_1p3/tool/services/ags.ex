defmodule Lti_1p3.Tool.Services.AGS do
  @moduledoc """
  Implementation of LTI Assignment and Grading Services (AGS) version 2.0.

  For information on the standard, see:
  https://www.imsglobal.org/spec/lti-ags/v2p0/
  """

  alias Lti_1p3.Services.HTTP.QueryFilters
  alias Lti_1p3.Services.HTTP.Request
  alias Lti_1p3.Tool.Services.AccessToken
  alias Lti_1p3.Tool.Services.AGS.Client
  alias Lti_1p3.Tool.Services.AGS.CompatibilityPolicy
  alias Lti_1p3.Tool.Services.AGS.Endpoint
  alias Lti_1p3.Tool.Services.AGS.Errors
  alias Lti_1p3.Tool.Services.AGS.LineItem
  alias Lti_1p3.Tool.Services.AGS.Page
  alias Lti_1p3.Tool.Services.AGS.Parser
  alias Lti_1p3.Tool.Services.AGS.Result
  alias Lti_1p3.Tool.Services.AGS.Score
  alias Lti_1p3.Tool.Services.AGS.ScopePolicy
  alias Lti_1p3.Tool.Services.AGS.Telemetry

  @lti_ags_claim_url "https://purl.imsglobal.org/spec/lti-ags/claim/endpoint"

  @lineitem_container_accept "application/vnd.ims.lis.v2.lineitemcontainer+json"
  @lineitem_accept "application/vnd.ims.lis.v2.lineitem+json"
  @score_content_type "application/vnd.ims.lis.v1.score+json"
  @result_container_accept "application/vnd.ims.lis.v2.resultcontainer+json"

  @type error_map :: Errors.error_map()

  @doc """
  Parses a launch claim map into a typed AGS endpoint.
  """
  @spec from_launch_claim(map()) :: {:ok, Endpoint.t()} | {:error, error_map()}
  def from_launch_claim(claim_map), do: Parser.parse_endpoint(claim_map)

  @doc """
  Lists a single line items page.

  Supported options:
  - `:resource_id`, `:tag`, `:limit`
  - `:retry_count` (default `0`)
  - `:page_index` (internal use)
  - `:compatibility` (LMS compatibility profile map)
  """
  @spec list_line_items(Endpoint.t(), AccessToken.t(), keyword()) ::
          {:ok, Page.t(LineItem.t())} | {:error, error_map()}
  def list_line_items(%Endpoint{} = endpoint, %AccessToken{} = access_token, opts \\ []) do
    with :ok <- preflight(endpoint, access_token, :list_line_items),
         {:ok, request_url} <- build_line_items_request_url(endpoint.line_items_url, opts),
         request_url <- CompatibilityPolicy.apply(:list_line_items, request_url, opts),
         {:ok, response} <-
           Client.request(:list_line_items, :get, request_url, access_token,
             retry_count: Keyword.get(opts, :retry_count, 0),
             expected_statuses: [200],
             headers: line_item_headers()
           ),
         {:ok, payload} <- decode_json_array(response.body, :list_line_items),
         {:ok, page} <-
           Parser.parse_line_items_page(
             payload,
             response.headers,
             Keyword.get(opts, :page_index, 1),
             request_url
           ) do
      Enum.each(page.items, fn line_item ->
        Telemetry.line_item(%{
          operation: :list_line_items,
          line_item_id: line_item.id,
          page_index: page.page_index
        })
      end)

      {:ok, page}
    end
  end

  @doc """
  Reads a single line item.
  """
  @spec read_line_item(String.t(), Endpoint.t(), AccessToken.t(), keyword()) ::
          {:ok, LineItem.t()} | {:error, error_map()}
  def read_line_item(
        line_item_url,
        %Endpoint{} = endpoint,
        %AccessToken{} = access_token,
        opts \\ []
      )
      when is_binary(line_item_url) do
    with :ok <- preflight(endpoint, access_token, :read_line_item),
         {:ok, response} <-
           Client.request(:read_line_item, :get, line_item_url, access_token,
             retry_count: Keyword.get(opts, :retry_count, 0),
             expected_statuses: [200],
             headers: [{"Accept", @lineitem_accept}, {"Content-Type", @lineitem_accept}]
           ),
         {:ok, payload} <- decode_json_map(response.body, :read_line_item),
         {:ok, line_item} <- Parser.parse_line_item(payload, :read_line_item) do
      Telemetry.line_item(%{operation: :read_line_item, line_item_id: line_item.id})
      {:ok, line_item}
    end
  end

  @doc """
  Creates a line item.
  """
  @spec create_line_item(Endpoint.t(), AccessToken.t(), map(), keyword()) ::
          {:ok, LineItem.t()} | {:error, error_map()}
  def create_line_item(%Endpoint{} = endpoint, %AccessToken{} = access_token, attrs, opts \\ [])
      when is_map(attrs) do
    with :ok <- preflight(endpoint, access_token, :create_line_item),
         {:ok, valid_attrs} <- Parser.validate_line_item_attrs(attrs, :create_line_item),
         body <- Jason.encode!(line_item_payload(valid_attrs)),
         {:ok, response} <-
           Client.request(:create_line_item, :post, endpoint.line_items_url, access_token,
             retry_count: Keyword.get(opts, :retry_count, 0),
             expected_statuses: [200, 201],
             headers: line_item_headers(),
             body: body
           ),
         {:ok, payload} <- decode_json_map(response.body, :create_line_item),
         {:ok, line_item} <- Parser.parse_line_item(payload, :create_line_item) do
      Telemetry.line_item(%{operation: :create_line_item, line_item_id: line_item.id})
      {:ok, line_item}
    end
  end

  @doc """
  Updates a line item.
  """
  @spec update_line_item(String.t(), Endpoint.t(), AccessToken.t(), map(), keyword()) ::
          {:ok, LineItem.t()} | {:error, error_map()}
  def update_line_item(
        line_item_url,
        %Endpoint{} = endpoint,
        %AccessToken{} = access_token,
        attrs,
        opts \\ []
      )
      when is_binary(line_item_url) and is_map(attrs) do
    with :ok <- preflight(endpoint, access_token, :update_line_item),
         {:ok, valid_attrs} <- Parser.validate_line_item_attrs(attrs, :update_line_item),
         body <- Jason.encode!(line_item_payload(Map.put(valid_attrs, :id, line_item_url))),
         {:ok, response} <-
           Client.request(:update_line_item, :put, line_item_url, access_token,
             retry_count: Keyword.get(opts, :retry_count, 0),
             expected_statuses: [200],
             headers: line_item_headers(),
             body: body
           ),
         {:ok, payload} <- decode_json_map(response.body, :update_line_item),
         {:ok, line_item} <- Parser.parse_line_item(payload, :update_line_item) do
      Telemetry.line_item(%{operation: :update_line_item, line_item_id: line_item.id})
      {:ok, line_item}
    end
  end

  @doc """
  Deletes a line item.
  """
  @spec delete_line_item(String.t(), Endpoint.t(), AccessToken.t(), keyword()) ::
          :ok | {:error, error_map()}
  def delete_line_item(
        line_item_url,
        %Endpoint{} = endpoint,
        %AccessToken{} = access_token,
        opts \\ []
      )
      when is_binary(line_item_url) do
    with :ok <- preflight(endpoint, access_token, :delete_line_item),
         {:ok, _response} <-
           Client.request(:delete_line_item, :delete, line_item_url, access_token,
             retry_count: Keyword.get(opts, :retry_count, 0),
             expected_statuses: [200, 202, 204],
             headers: line_item_headers()
           ) do
      Telemetry.line_item(%{operation: :delete_line_item, line_item_id: line_item_url})
      :ok
    end
  end

  @doc """
  Posts a score to an existing line item.
  """
  @spec post_score(String.t(), Endpoint.t(), AccessToken.t(), Score.t() | map(), keyword()) ::
          :ok | {:error, error_map()}
  def post_score(
        line_item_url,
        %Endpoint{} = endpoint,
        %AccessToken{} = access_token,
        score,
        opts \\ []
      )
      when is_binary(line_item_url) do
    with :ok <- preflight(endpoint, access_token, :post_score),
         {:ok, valid_score} <- Parser.validate_score(score, :post_score),
         score_url <- Request.append_path(line_item_url, "scores"),
         body <- Jason.encode!(valid_score),
         {:ok, _response} <-
           Client.request(:post_score, :post, score_url, access_token,
             retry_count: Keyword.get(opts, :retry_count, 0),
             expected_statuses: [200, 201, 202, 204],
             headers: [{"Content-Type", @score_content_type}],
             body: body
           ) do
      Telemetry.result(%{operation: :post_score, line_item_url: line_item_url})
      :ok
    end
  end

  @doc """
  Lists a single results page.

  Supported options:
  - `:limit`, `:user_id`
  - `:retry_count` (default `0`)
  - `:page_index` (internal use)
  """
  @spec list_results(String.t(), Endpoint.t(), AccessToken.t(), keyword()) ::
          {:ok, Page.t(Result.t())} | {:error, error_map()}
  def list_results(
        line_item_url,
        %Endpoint{} = endpoint,
        %AccessToken{} = access_token,
        opts \\ []
      )
      when is_binary(line_item_url) do
    with :ok <- preflight(endpoint, access_token, :list_results),
         request_url <- Request.append_path(line_item_url, "results"),
         {:ok, request_url} <- build_results_request_url(request_url, opts),
         {:ok, response} <-
           Client.request(:list_results, :get, request_url, access_token,
             retry_count: Keyword.get(opts, :retry_count, 0),
             expected_statuses: [200],
             headers: [{"Accept", @result_container_accept}, {"Content-Type", "application/json"}]
           ),
         {:ok, payload} <- decode_json_array(response.body, :list_results),
         {:ok, page} <-
           Parser.parse_results_page(
             payload,
             response.headers,
             Keyword.get(opts, :page_index, 1),
             request_url
           ) do
      Enum.each(page.items, fn result ->
        Telemetry.result(%{
          operation: :list_results,
          user_id: result.userId,
          page_index: page.page_index
        })
      end)

      {:ok, page}
    end
  end

  @doc """
  Traverses results across pages up to `:max_pages`.
  """
  @spec fetch_all_results(String.t(), Endpoint.t(), AccessToken.t(), keyword()) ::
          {:ok, [Result.t()]} | {:error, error_map()}
  def fetch_all_results(
        line_item_url,
        %Endpoint{} = endpoint,
        %AccessToken{} = access_token,
        opts \\ []
      ) do
    max_pages = Keyword.get(opts, :max_pages, 100)

    do_fetch_all_results(
      line_item_url,
      endpoint,
      access_token,
      opts,
      1,
      max_pages,
      [],
      true
    )
  end

  @doc """
  Backward-compatible single-call helper for posting a score.

  Preserves return shape `{:ok, body} | {:error, "Error posting score"}`.
  """
  @spec post_score(Score.t(), LineItem.t(), AccessToken.t()) ::
          {:ok, term()} | {:error, String.t()}
  def post_score(%Score{} = score, %LineItem{} = line_item, %AccessToken{} = access_token) do
    endpoint = legacy_endpoint(line_item.id)

    score_url = Request.append_path(line_item.id, "scores")

    case Client.request(:post_score, :post, score_url, access_token,
           expected_statuses: [200, 201],
           headers: [{"Content-Type", @score_content_type}],
           body: Jason.encode!(score)
         ) do
      {:ok, %{body: body}} ->
        Telemetry.result(%{operation: :post_score, line_item_url: line_item.id})
        {:ok, body}

      {:error, _error} ->
        maybe_scope_denied(endpoint, access_token, :post_score)
        {:error, "Error posting score"}
    end
  end

  @doc """
  Legacy helper: fetches one line items page and returns only items.

  Preserves return shape `{:ok, [LineItem.t()]} | {:error, "Error retrieving all line items"}`.
  """
  @spec fetch_line_items(String.t(), AccessToken.t()) ::
          {:ok, [LineItem.t()]} | {:error, String.t()}
  def fetch_line_items(line_items_service_url, %AccessToken{} = access_token) do
    request_url =
      CompatibilityPolicy.apply(:list_line_items, line_items_service_url,
        compatibility: %{default_line_items_limit: 1000}
      )

    with {:ok, response} <-
           Client.request(:list_line_items, :get, request_url, access_token,
             expected_statuses: [200],
             headers: line_item_headers()
           ),
         {:ok, payload} <- decode_json_array(response.body, :list_line_items),
         {:ok, page} <- Parser.parse_line_items_page(payload, response.headers, 1, request_url) do
      {:ok, page.items}
    else
      _ -> {:error, "Error retrieving all line items"}
    end
  end

  @doc """
  Legacy helper: creates a line item by primitive arguments.

  Preserves return shape `{:ok, line_item} | {:error, "Error creating new line item"}`.
  """
  @spec create_line_item(
          String.t(),
          String.t() | integer(),
          float() | integer(),
          String.t(),
          AccessToken.t()
        ) ::
          {:ok, LineItem.t()} | {:error, String.t()}
  def create_line_item(
        line_items_service_url,
        resource_id,
        score_maximum,
        label,
        %AccessToken{} = access_token
      ) do
    attrs = %{
      scoreMaximum: score_maximum,
      resourceId: LineItem.to_resource_id(resource_id),
      label: label
    }

    endpoint = legacy_endpoint(line_items_service_url)

    case create_line_item(endpoint, access_token, attrs) do
      {:ok, line_item} -> {:ok, line_item}
      {:error, _error} -> {:error, "Error creating new line item"}
    end
  end

  @doc """
  Legacy helper: updates a line item by struct and changes map.

  Preserves return shape `{:ok, line_item} | {:error, "Error updating existing line item"}`.
  """
  @spec update_line_item(LineItem.t(), map(), AccessToken.t()) ::
          {:ok, LineItem.t()} | {:error, String.t()}
  def update_line_item(%LineItem{} = line_item, changes, %AccessToken{} = access_token) do
    attrs = %{
      scoreMaximum: Map.get(changes, :scoreMaximum, line_item.scoreMaximum),
      resourceId: line_item.resourceId,
      label: Map.get(changes, :label, line_item.label)
    }

    endpoint = legacy_endpoint(line_item.id)

    case update_line_item(line_item.id, endpoint, access_token, attrs) do
      {:ok, updated} -> {:ok, updated}
      {:error, _error} -> {:error, "Error updating existing line item"}
    end
  end

  @doc """
  Legacy helper: fetches or creates a line item by resource id.

  Preserves return shape `{:ok, line_item} | {:error, "Error retrieving existing line items"}`.
  """
  @spec fetch_or_create_line_item(
          String.t(),
          String.t() | integer(),
          (-> float() | integer()),
          String.t(),
          AccessToken.t()
        ) :: {:ok, LineItem.t()} | {:error, String.t()}
  def fetch_or_create_line_item(
        line_items_service_url,
        resource_id,
        maximum_score_provider,
        label,
        %AccessToken{} = access_token
      ) do
    line_item_resource_id = LineItem.to_resource_id(resource_id)

    endpoint = legacy_endpoint(line_items_service_url)

    with {:ok, page} <-
           list_line_items(endpoint, access_token,
             resource_id: line_item_resource_id,
             limit: 1,
             compatibility: %{default_line_items_limit: 1000}
           ) do
      case page.items do
        [] ->
          create_line_item(
            endpoint,
            access_token,
            %{
              scoreMaximum: maximum_score_provider.(),
              resourceId: line_item_resource_id,
              label: label
            }
          )

        [%LineItem{} = existing | _rest] ->
          if existing.label != label do
            update_line_item(existing.id, endpoint, access_token, %{
              scoreMaximum: existing.scoreMaximum,
              resourceId: existing.resourceId,
              label: label
            })
          else
            {:ok, existing}
          end
      end
    else
      _ -> {:error, "Error retrieving existing line items"}
    end
  end

  @doc """
  Returns true if grade passback service is enabled with minimum scopes for line item + score.
  """
  @spec grade_passback_enabled?(map()) :: boolean()
  def grade_passback_enabled?(lti_launch_params) do
    case Map.get(lti_launch_params, @lti_ags_claim_url) do
      nil ->
        false

      config ->
        Map.has_key?(config, "lineitems") and
          has_scope?(config, "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem") and
          has_scope?(config, "https://purl.imsglobal.org/spec/lti-ags/scope/score")
    end
  end

  @doc """
  Returns the line items URL from LTI launch params.

  If a registration is present, uses registration `line_items_service_domain` + line items path.
  """
  @spec get_line_items_url(map(), map()) :: String.t() | nil
  def get_line_items_url(lti_launch_params, registration \\ %{}) do
    line_items_url =
      lti_launch_params
      |> Map.get(@lti_ags_claim_url, %{})
      |> Map.get("lineitems")

    unless is_nil(line_items_url) do
      %URI{path: line_items_path} = URI.parse(line_items_url)

      registration
      |> get_line_items_domain(line_items_url)
      |> URI.parse()
      |> Map.put(:path, line_items_path)
      |> URI.to_string()
    end
  end

  @doc """
  Returns true if the LTI AGS claim has a particular scope URL.
  """
  @spec has_scope?(map(), String.t()) :: boolean()
  def has_scope?(lti_ags_claim, scope_url) do
    lti_ags_claim
    |> Map.get("scope", [])
    |> Enum.any?(&(&1 == scope_url))
  end

  @doc """
  Returns legacy required scopes for AGS grade passback token requests.
  """
  @spec required_scopes() :: [String.t()]
  def required_scopes do
    [
      "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem",
      "https://purl.imsglobal.org/spec/lti-ags/scope/score"
    ]
  end

  @doc """
  Returns complete AGS scope set by operation.
  """
  @spec required_scopes(atom()) :: [String.t()]
  def required_scopes(:all), do: ScopePolicy.all_scopes()
  def required_scopes(operation), do: ScopePolicy.required_scopes_for(operation)

  defp do_fetch_all_results(
         _line_item_or_results_url,
         _endpoint,
         _access_token,
         _opts,
         page_index,
         max_pages,
         _acc,
         _append_results?
       )
       when page_index > max_pages do
    {:error, Errors.max_pages_exceeded(:list_results, max_pages)}
  end

  defp do_fetch_all_results(
         line_item_or_results_url,
         endpoint,
         access_token,
         opts,
         page_index,
         max_pages,
         acc,
         append_results?
       ) do
    request_opts = Keyword.put(opts, :page_index, page_index)

    request_url =
      if append_results? do
        Request.append_path(line_item_or_results_url, "results")
      else
        line_item_or_results_url
      end

    with :ok <- preflight(endpoint, access_token, :list_results),
         {:ok, request_url} <- build_results_request_url(request_url, request_opts),
         {:ok, response} <-
           Client.request(:list_results, :get, request_url, access_token,
             retry_count: Keyword.get(request_opts, :retry_count, 0),
             expected_statuses: [200],
             headers: [{"Accept", @result_container_accept}, {"Content-Type", "application/json"}]
           ),
         {:ok, payload} <- decode_json_array(response.body, :list_results),
         {:ok, %Page{} = page} <-
           Parser.parse_results_page(payload, response.headers, page_index, request_url) do
      merged = acc ++ page.items

      if page.next_url do
        do_fetch_all_results(
          page.next_url,
          endpoint,
          access_token,
          drop_filter_opts(opts),
          page_index + 1,
          max_pages,
          merged,
          false
        )
      else
        {:ok, merged}
      end
    end
  end

  defp build_line_items_request_url(base_url, opts) do
    filters = opts |> Keyword.take([:resource_id, :tag, :limit])

    with {:ok, normalized_filters} <- QueryFilters.normalize(filters) do
      {:ok, QueryFilters.append_to_url(base_url, normalized_filters)}
    else
      {:error, reason} -> {:error, Errors.invalid_filter(reason)}
    end
  end

  defp build_results_request_url(base_url, opts) do
    filters = opts |> Keyword.take([:limit, :user_id])

    with {:ok, normalized_filters} <- QueryFilters.normalize(filters) do
      {:ok, QueryFilters.append_to_url(base_url, normalized_filters)}
    else
      {:error, reason} -> {:error, Errors.invalid_filter(reason)}
    end
  end

  defp decode_json_map(body, operation) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, payload} when is_map(payload) ->
        {:ok, payload}

      {:ok, _payload} ->
        {:error, Errors.invalid_payload(operation, :invalid_json_shape)}

      {:error, error} ->
        {:error, Errors.invalid_payload(operation, :invalid_json, %{error: inspect(error)})}
    end
  end

  defp decode_json_map(_body, operation),
    do: {:error, Errors.invalid_payload(operation, :invalid_response_body)}

  defp decode_json_array(body, operation) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, payload} when is_list(payload) ->
        {:ok, payload}

      {:ok, _payload} ->
        {:error, Errors.invalid_payload(operation, :invalid_json_shape)}

      {:error, error} ->
        {:error, Errors.invalid_payload(operation, :invalid_json, %{error: inspect(error)})}
    end
  end

  defp decode_json_array(_body, operation),
    do: {:error, Errors.invalid_payload(operation, :invalid_response_body)}

  defp preflight(endpoint, access_token, operation) do
    case ScopePolicy.preflight(endpoint, access_token, operation) do
      :ok ->
        :ok

      {:error, error} ->
        Telemetry.scope_denied(%{
          operation: operation,
          required_scope: get_in(error, [:details, :required_scope]),
          source: get_in(error, [:details, :source])
        })

        {:error, error}
    end
  end

  defp maybe_scope_denied(endpoint, access_token, operation) do
    case ScopePolicy.preflight(endpoint, access_token, operation) do
      :ok ->
        :ok

      {:error, error} ->
        Telemetry.scope_denied(%{
          operation: operation,
          required_scope: get_in(error, [:details, :required_scope]),
          source: get_in(error, [:details, :source])
        })
    end
  end

  defp line_item_headers do
    [
      {"Accept", @lineitem_container_accept},
      {"Content-Type", @lineitem_accept}
    ]
  end

  defp line_item_payload(attrs) do
    %LineItem{
      id: Map.get(attrs, :id),
      scoreMaximum: Map.get(attrs, :scoreMaximum),
      resourceId: Map.get(attrs, :resourceId),
      label: Map.get(attrs, :label),
      tag: Map.get(attrs, :tag),
      resourceLinkId: Map.get(attrs, :resourceLinkId)
    }
  end

  defp drop_filter_opts(opts), do: Keyword.drop(opts, [:limit, :user_id])

  defp get_line_items_domain(%{line_items_service_domain: domain}, default)
       when is_nil(domain) or domain == "",
       do: default

  defp get_line_items_domain(%{line_items_service_domain: domain}, _default), do: domain
  defp get_line_items_domain(_registration, default), do: default

  defp legacy_endpoint(line_items_url) do
    %Endpoint{
      line_items_url: line_items_url,
      line_item_url: nil,
      scopes: ScopePolicy.all_scopes(),
      service_versions: ["2.0"]
    }
  end
end
