defmodule Lti_1p3.Tool.Services.NRPS.ScopePolicy do
  @moduledoc """
  Scope preflight checks for tool NRPS operations.
  """

  alias Lti_1p3.Tool.Services.AccessToken
  alias Lti_1p3.Tool.Services.NRPS.Endpoint
  alias Lti_1p3.Tool.Services.NRPS.Errors

  @context_membership_scope "https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly"

  @spec required_scope() :: String.t()
  def required_scope, do: @context_membership_scope

  @spec preflight(Endpoint.t(), AccessToken.t()) :: :ok | {:error, Errors.error_map()}
  def preflight(%Endpoint{}, %AccessToken{} = token) do
    available_scopes = parse_scope_string(token.scope)

    if has_scope?(available_scopes, required_scope()) do
      :ok
    else
      {:error, Errors.insufficient_scope(required_scope(), available_scopes)}
    end
  end

  @spec has_scope?([String.t()], String.t()) :: boolean()
  def has_scope?(scopes, required_scope) do
    Enum.any?(scopes, &(&1 == required_scope))
  end

  @spec parse_scope_string(String.t() | nil) :: [String.t()]
  def parse_scope_string(nil), do: []
  def parse_scope_string(""), do: []

  def parse_scope_string(scope_string) when is_binary(scope_string) do
    scope_string
    |> String.split(" ", trim: true)
    |> Enum.uniq()
  end
end
