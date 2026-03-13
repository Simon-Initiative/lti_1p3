defmodule Lti_1p3.Platform.Services.AGS.Errors do
  @moduledoc """
  Structured platform AGS error helpers with stable reason atoms.
  """

  @type error_map :: %{
          required(:reason) => atom(),
          required(:operation) => atom(),
          required(:http_status) => non_neg_integer() | nil,
          required(:retryable) => boolean(),
          required(:msg) => String.t(),
          optional(:details) => map()
        }

  @spec invalid_context_shape() :: error_map()
  def invalid_context_shape do
    error(
      :invalid_context_shape,
      :authorize_operation,
      "Invalid AGS context shape",
      nil,
      false,
      %{}
    )
  end

  @spec invalid_context_input(atom()) :: error_map()
  def invalid_context_input(reason) do
    error(
      :invalid_context_input,
      :authorize_operation,
      "Invalid AGS context input",
      422,
      false,
      %{
        reason: reason
      }
    )
  end

  @spec invalid_scope_claim(atom()) :: error_map()
  def invalid_scope_claim(reason) do
    error(:invalid_scope_claim, :authorize_operation, "Invalid AGS scope claim", 403, false, %{
      reason: reason
    })
  end

  @spec insufficient_scope(atom(), String.t(), [String.t()]) :: error_map()
  def insufficient_scope(operation, required_scope, available_scopes) do
    error(:insufficient_scope, operation, "Missing required AGS scope", 403, false, %{
      required_scope: required_scope,
      available_scopes: available_scopes
    })
  end

  @spec invalid_deployment(atom(), String.t(), String.t() | nil) :: error_map()
  def invalid_deployment(operation, expected_deployment_id, claim_deployment_id) do
    error(:invalid_deployment, operation, "Deployment mismatch for AGS operation", 403, false, %{
      expected_deployment_id: expected_deployment_id,
      claim_deployment_id: claim_deployment_id
    })
  end

  @spec invalid_context(atom(), String.t(), String.t() | nil) :: error_map()
  def invalid_context(operation, expected_context_id, claim_context_id) do
    error(:invalid_context, operation, "Context mismatch for AGS operation", 403, false, %{
      expected_context_id: expected_context_id,
      claim_context_id: claim_context_id
    })
  end

  @spec invalid_attrs(atom(), atom(), map()) :: error_map()
  def invalid_attrs(operation, reason, details \\ %{}) do
    error(:invalid_attrs, operation, "Invalid AGS request attributes", 422, false, %{
      reason: reason,
      details: details
    })
  end

  @spec invalid_opts(atom(), atom()) :: error_map()
  def invalid_opts(operation, reason) do
    error(:invalid_opts, operation, "Invalid AGS request options", 422, false, %{reason: reason})
  end

  @spec not_found(atom(), atom(), String.t()) :: error_map()
  def not_found(operation, resource, identifier) do
    error(:not_found, operation, "AGS resource not found", 404, false, %{
      resource: resource,
      identifier: identifier
    })
  end

  @spec provider_error(atom(), term()) :: error_map()
  def provider_error(operation, reason) do
    error(:provider_error, operation, "AGS provider operation failed", 500, false, %{
      reason: normalize_reason(reason)
    })
  end

  @spec internal(atom(), atom()) :: error_map()
  def internal(operation, reason) do
    error(:internal_error, operation, "AGS internal error", 500, false, %{reason: reason})
  end

  @spec normalize_provider_error(atom(), term(), String.t()) :: error_map()
  def normalize_provider_error(
        operation,
        %Lti_1p3.DataProviderError{reason: :not_found},
        identifier
      ) do
    not_found(operation, :line_item, identifier)
  end

  def normalize_provider_error(operation, %Lti_1p3.DataProviderError{reason: reason}, _identifier) do
    provider_error(operation, reason)
  end

  def normalize_provider_error(operation, {:not_found, resource, identifier}, _identifier) do
    not_found(operation, resource, to_string(identifier))
  end

  def normalize_provider_error(operation, reason, _identifier) do
    provider_error(operation, reason)
  end

  defp error(reason, operation, msg, http_status, retryable, details) do
    %{
      reason: reason,
      operation: operation,
      http_status: http_status,
      retryable: retryable,
      msg: msg,
      details: details
    }
  end

  defp normalize_reason(reason) when is_atom(reason), do: reason
  defp normalize_reason(reason), do: inspect(reason)
end
