defmodule Lti_1p3.Tool.Services.NRPS.Parser do
  @moduledoc """
  NRPS launch-claim and membership payload parsing.
  """

  alias Lti_1p3.Services.HTTP.LinkHeader
  alias Lti_1p3.Tool.Services.NRPS.Endpoint
  alias Lti_1p3.Tool.Services.NRPS.Errors
  alias Lti_1p3.Tool.Services.NRPS.Membership
  alias Lti_1p3.Tool.Services.NRPS.MembershipPage

  @nrps_claim_url "https://purl.imsglobal.org/spec/lti-nrps/claim/namesroleservice"
  @context_memberships_url_key "context_memberships_url"
  @scope_key "scope"
  @service_versions_key "service_versions"

  @spec parse_endpoint(map()) :: {:ok, Endpoint.t()} | {:error, Errors.error_map()}
  def parse_endpoint(claim_map) when is_map(claim_map) do
    with {:ok, claim} <- fetch_nrps_claim(claim_map),
         {:ok, context_memberships_url} <- parse_url(claim),
         {:ok, scopes} <- parse_scopes(claim),
         {:ok, service_versions} <- parse_service_versions(claim) do
      {:ok,
       %Endpoint{
         context_memberships_url: context_memberships_url,
         scopes: scopes,
         service_versions: service_versions
       }}
    end
  end

  def parse_endpoint(_), do: {:error, Errors.invalid_claim(:invalid_claim_shape)}

  @spec parse_page(map(), [{String.t(), String.t()}], pos_integer(), String.t()) ::
          {:ok, MembershipPage.t()} | {:error, Errors.error_map()}
  def parse_page(payload, headers, page_index, request_url)
      when is_map(payload) and is_list(headers) and is_integer(page_index) and page_index > 0 do
    with {:ok, raw_memberships} <- fetch_members(payload),
         {:ok, memberships} <- parse_memberships(raw_memberships) do
      next_url =
        headers
        |> link_header_value()
        |> LinkHeader.next_url()

      {:ok,
       %MembershipPage{
         memberships: memberships,
         next_url: next_url,
         page_index: page_index,
         request_url: request_url
       }}
    end
  end

  def parse_page(_payload, _headers, _page_index, _request_url) do
    {:error, Errors.invalid_payload(:invalid_page_shape)}
  end

  defp fetch_nrps_claim(claim_map) do
    case Map.get(claim_map, @nrps_claim_url) do
      claim when is_map(claim) -> {:ok, claim}
      _ -> {:error, Errors.invalid_claim(:missing_nrps_claim)}
    end
  end

  defp parse_url(claim) do
    case Map.get(claim, @context_memberships_url_key) do
      url when is_binary(url) ->
        case URI.parse(url) do
          %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and is_binary(host) ->
            {:ok, url}

          _ ->
            {:error, Errors.invalid_claim(:invalid_context_memberships_url)}
        end

      _ ->
        {:error, Errors.invalid_claim(:missing_context_memberships_url)}
    end
  end

  defp parse_scopes(claim) do
    scopes =
      case Map.get(claim, @scope_key, []) do
        scopes when is_list(scopes) -> scopes
        scope when is_binary(scope) -> String.split(scope, " ", trim: true)
        _ -> []
      end

    {:ok, Enum.filter(scopes, &is_binary/1)}
  end

  defp parse_service_versions(claim) do
    versions =
      case Map.get(claim, @service_versions_key, []) do
        versions when is_list(versions) -> Enum.filter(versions, &is_binary/1)
        _ -> []
      end

    {:ok, versions}
  end

  defp fetch_members(payload) do
    case Map.get(payload, "members") do
      members when is_list(members) -> {:ok, members}
      _ -> {:error, Errors.invalid_payload(:missing_members)}
    end
  end

  defp parse_memberships(raw_memberships) do
    raw_memberships
    |> Enum.reduce_while({:ok, []}, fn raw, {:ok, acc} ->
      case parse_membership(raw) do
        {:ok, membership} -> {:cont, {:ok, [membership | acc]}}
        {:error, _} = error -> {:halt, error}
      end
    end)
    |> case do
      {:ok, memberships} -> {:ok, Enum.reverse(memberships)}
      error -> error
    end
  end

  defp parse_membership(raw) when is_map(raw) do
    roles =
      raw
      |> Map.get("roles", [])
      |> normalize_roles()

    {:ok,
     %Membership{
       status: Map.get(raw, "status"),
       name: Map.get(raw, "name"),
       picture: Map.get(raw, "picture"),
       given_name: Map.get(raw, "given_name"),
       middle_name: Map.get(raw, "middle_name"),
       family_name: Map.get(raw, "family_name"),
       email: Map.get(raw, "email"),
       user_id: Map.get(raw, "user_id"),
       roles: roles
     }}
  end

  defp parse_membership(_), do: {:error, Errors.invalid_payload(:invalid_membership)}

  defp normalize_roles(raw_roles) when is_list(raw_roles) do
    raw_roles
    |> Enum.filter(&is_binary/1)
    |> Enum.map(&normalize_role/1)
  end

  defp normalize_roles(_), do: []

  defp normalize_role(role) do
    case String.split(role, "#") do
      [_prefix, value] when value != "" -> String.downcase(value)
      _ -> String.downcase(role)
    end
  end

  defp link_header_value(headers) do
    Enum.find_value(headers, fn
      {key, value} when is_binary(key) and is_binary(value) ->
        if String.downcase(key) == "link", do: value, else: nil

      _ ->
        nil
    end)
  end
end
