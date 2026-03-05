defmodule Lti_1p3.Tool.Services.AGS.Errors do
  @moduledoc """
  Structured AGS error helpers with stable reason atoms.
  """

  @type error_map :: %{
          required(:reason) => atom(),
          required(:operation) => atom(),
          required(:http_status) => non_neg_integer() | nil,
          required(:retryable) => boolean(),
          required(:msg) => String.t(),
          optional(:details) => map()
        }

  @spec invalid_claim(atom(), atom()) :: error_map()
  def invalid_claim(reason, operation \\ :from_launch_claim) do
    error(reason, operation, "Invalid AGS launch claim", nil, false, %{reason: reason})
  end

  @spec invalid_attrs(atom(), atom(), map()) :: error_map()
  def invalid_attrs(operation, reason, details \\ %{}) do
    error(
      :invalid_attrs,
      operation,
      "Invalid AGS request attributes",
      nil,
      false,
      Map.put(details, :reason, reason)
    )
  end

  @spec invalid_payload(atom(), atom(), map()) :: error_map()
  def invalid_payload(operation, reason, details \\ %{}) do
    error(
      :invalid_payload,
      operation,
      "Invalid AGS response payload",
      nil,
      false,
      Map.put(details, :reason, reason)
    )
  end

  @spec invalid_filter(atom()) :: error_map()
  def invalid_filter(reason) do
    error(:invalid_filter, :list_line_items, "Invalid AGS filter options", nil, false, %{
      reason: reason
    })
  end

  @spec insufficient_scope(atom(), String.t(), [String.t()], :token | :endpoint) :: error_map()
  def insufficient_scope(operation, required_scope, available_scopes, source) do
    error(:insufficient_scope, operation, "Missing required AGS scope", nil, false, %{
      required_scope: required_scope,
      available_scopes: available_scopes,
      source: source
    })
  end

  @spec request_failed(atom(), non_neg_integer(), boolean()) :: error_map()
  def request_failed(operation, http_status, retryable?) do
    error(:request_failed, operation, "AGS request failed", http_status, retryable?, %{})
  end

  @spec transport_error(atom(), term(), boolean()) :: error_map()
  def transport_error(operation, error_term, retryable?) do
    error(:transport_error, operation, "AGS request transport error", nil, retryable?, %{
      error: inspect(error_term)
    })
  end

  @spec max_pages_exceeded(atom(), pos_integer()) :: error_map()
  def max_pages_exceeded(operation, max_pages) do
    error(:max_pages_exceeded, operation, "AGS traversal exceeded max_pages", nil, false, %{
      max_pages: max_pages
    })
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
end
