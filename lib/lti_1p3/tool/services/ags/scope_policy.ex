defmodule Lti_1p3.Tool.Services.AGS.ScopePolicy do
  @moduledoc """
  Scope preflight checks for tool AGS operations.
  """

  alias Lti_1p3.Services.AGS.ScopeSet
  alias Lti_1p3.Tool.Services.AccessToken
  alias Lti_1p3.Tool.Services.AGS.Endpoint
  alias Lti_1p3.Tool.Services.AGS.Errors

  @spec all_scopes() :: [String.t()]
  def all_scopes, do: ScopeSet.all_scopes()

  @spec required_scopes_for(atom()) :: [String.t()]
  def required_scopes_for(operation), do: ScopeSet.required_scopes_for(operation)

  @spec preflight(Endpoint.t(), AccessToken.t(), atom()) :: :ok | {:error, Errors.error_map()}
  def preflight(%Endpoint{} = endpoint, %AccessToken{} = token, operation) do
    token_scopes = parse_scope_string(token.scope)
    endpoint_scopes = endpoint.scopes || []

    required_scopes = required_scopes_for(operation)

    if allowed?(required_scopes, token_scopes) and allowed?(required_scopes, endpoint_scopes) do
      :ok
    else
      with {:token, false} <- {:token, allowed?(required_scopes, token_scopes)} do
        {:error, Errors.insufficient_scope(operation, hd(required_scopes), token_scopes, :token)}
      else
        {:endpoint, false} ->
          {:error,
           Errors.insufficient_scope(operation, hd(required_scopes), endpoint_scopes, :endpoint)}

        _ ->
          {:error,
           Errors.insufficient_scope(operation, hd(required_scopes), token_scopes, :token)}
      end
    end
  end

  @spec parse_scope_string(String.t() | nil) :: [String.t()]
  def parse_scope_string(scope_string), do: ScopeSet.parse_scope_string(scope_string)

  @spec has_scope?([String.t()], String.t()) :: boolean()
  def has_scope?(scopes, required_scope), do: ScopeSet.has_scope?(scopes, required_scope)

  defp allowed?([], _available), do: true

  defp allowed?(required_scopes, available_scopes) do
    ScopeSet.allows_any?(available_scopes, required_scopes)
  end
end
