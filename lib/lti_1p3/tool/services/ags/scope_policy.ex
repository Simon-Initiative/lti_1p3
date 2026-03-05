defmodule Lti_1p3.Tool.Services.AGS.ScopePolicy do
  @moduledoc """
  Scope preflight checks for tool AGS operations.
  """

  alias Lti_1p3.Tool.Services.AccessToken
  alias Lti_1p3.Tool.Services.AGS.Endpoint
  alias Lti_1p3.Tool.Services.AGS.Errors

  @lineitem_scope "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem"
  @lineitem_readonly_scope "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem.readonly"
  @score_scope "https://purl.imsglobal.org/spec/lti-ags/scope/score"
  @result_readonly_scope "https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly"

  @spec all_scopes() :: [String.t()]
  def all_scopes do
    [@lineitem_scope, @lineitem_readonly_scope, @score_scope, @result_readonly_scope]
  end

  @spec required_scopes_for(atom()) :: [String.t()]
  def required_scopes_for(operation) do
    case operation do
      :list_line_items -> [@lineitem_scope, @lineitem_readonly_scope]
      :read_line_item -> [@lineitem_scope, @lineitem_readonly_scope]
      :create_line_item -> [@lineitem_scope]
      :update_line_item -> [@lineitem_scope]
      :delete_line_item -> [@lineitem_scope]
      :post_score -> [@score_scope]
      :list_results -> [@result_readonly_scope]
      _ -> []
    end
  end

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
  def parse_scope_string(nil), do: []
  def parse_scope_string(""), do: []

  def parse_scope_string(scope_string) when is_binary(scope_string) do
    scope_string
    |> String.split(" ", trim: true)
    |> Enum.uniq()
  end

  @spec has_scope?([String.t()], String.t()) :: boolean()
  def has_scope?(scopes, required_scope) do
    Enum.any?(scopes, &(&1 == required_scope))
  end

  defp allowed?([], _available), do: true

  defp allowed?(required_scopes, available_scopes) do
    Enum.any?(required_scopes, fn required_scope ->
      has_scope?(available_scopes, required_scope)
    end)
  end
end
