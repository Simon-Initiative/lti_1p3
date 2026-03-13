defmodule Lti_1p3.Services.AGS.ScopeSet do
  @moduledoc """
  Shared AGS scope constants and operation mappings.
  """

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

  @spec parse_scope_string(String.t() | [String.t()] | nil) :: [String.t()]
  def parse_scope_string(nil), do: []
  def parse_scope_string(""), do: []

  def parse_scope_string(scope_string) when is_binary(scope_string) do
    scope_string
    |> String.split(" ", trim: true)
    |> Enum.uniq()
  end

  def parse_scope_string(scopes) when is_list(scopes) do
    scopes
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end

  @spec has_scope?([String.t()], String.t()) :: boolean()
  def has_scope?(scopes, required_scope) do
    Enum.any?(scopes, &(&1 == required_scope))
  end

  @spec allows_any?([String.t()], [String.t()]) :: boolean()
  def allows_any?(_available_scopes, []), do: true

  def allows_any?(available_scopes, required_scopes) do
    Enum.any?(required_scopes, fn required_scope ->
      has_scope?(available_scopes, required_scope)
    end)
  end
end
