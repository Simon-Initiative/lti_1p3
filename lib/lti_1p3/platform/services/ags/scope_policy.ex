defmodule Lti_1p3.Platform.Services.AGS.ScopePolicy do
  @moduledoc """
  Scope, deployment, and context authorization checks for platform AGS operations.
  """

  alias Lti_1p3.Platform.Services.AGS.Context
  alias Lti_1p3.Platform.Services.AGS.Errors
  alias Lti_1p3.Services.AGS.ScopeSet

  @deployment_claim_key "https://purl.imsglobal.org/spec/lti/claim/deployment_id"
  @context_claim_key "https://purl.imsglobal.org/spec/lti/claim/context"

  @spec required_scopes(atom()) :: [String.t()]
  def required_scopes(operation), do: ScopeSet.required_scopes_for(operation)

  @spec authorize_operation(map(), atom(), Context.t()) :: :ok | {:error, Errors.error_map()}
  def authorize_operation(claims, operation, %Context{} = context) when is_map(claims) do
    required_scopes = required_scopes(operation)

    with :ok <- authorize_deployment(claims, operation, context),
         :ok <- authorize_context(claims, operation, context),
         :ok <- authorize_scope(claims, operation, context, required_scopes) do
      :ok
    end
  end

  def authorize_operation(_claims, _operation, _context) do
    {:error, Errors.invalid_context_shape()}
  end

  defp authorize_scope(_claims, _operation, _context, []), do: :ok

  defp authorize_scope(claims, operation, %Context{} = context, required_scopes) do
    claim_scopes = ScopeSet.parse_scope_string(Map.get(claims, "scope"))
    available_scopes = Enum.uniq(claim_scopes ++ context.scopes)

    if ScopeSet.allows_any?(available_scopes, required_scopes) do
      :ok
    else
      {:error, Errors.insufficient_scope(operation, hd(required_scopes), available_scopes)}
    end
  end

  defp authorize_deployment(claims, operation, %Context{deployment_id: expected_deployment_id}) do
    claim_deployment_id = Map.get(claims, @deployment_claim_key)

    if claim_deployment_id == expected_deployment_id do
      :ok
    else
      {:error, Errors.invalid_deployment(operation, expected_deployment_id, claim_deployment_id)}
    end
  end

  defp authorize_context(claims, operation, %Context{context_id: expected_context_id}) do
    claim_context_id =
      claims
      |> Map.get(@context_claim_key, %{})
      |> case do
        %{"id" => id} when is_binary(id) -> id
        _ -> nil
      end

    if claim_context_id == expected_context_id do
      :ok
    else
      {:error, Errors.invalid_context(operation, expected_context_id, claim_context_id)}
    end
  end
end
