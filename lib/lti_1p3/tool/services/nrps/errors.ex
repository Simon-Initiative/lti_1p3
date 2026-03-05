defmodule Lti_1p3.Tool.Services.NRPS.Errors do
  @moduledoc """
  Structured NRPS error helpers with stable reason atoms.
  """

  @type error_map :: %{
          required(:reason) => atom(),
          required(:msg) => String.t(),
          optional(:details) => map(),
          optional(:retryable) => boolean()
        }

  @spec invalid_claim(atom(), map()) :: error_map()
  def invalid_claim(reason, details \\ %{}) do
    error(reason, "Invalid NRPS launch claim", details)
  end

  @spec insufficient_scope(String.t(), [String.t()]) :: error_map()
  def insufficient_scope(required_scope, available_scopes) do
    error(:insufficient_scope, "Missing required NRPS scope", %{
      required_scope: required_scope,
      available_scopes: available_scopes
    })
  end

  @spec invalid_filter(atom()) :: error_map()
  def invalid_filter(reason) do
    error(:invalid_filter, "Invalid NRPS filter options", %{reason: reason})
  end

  @spec invalid_payload(atom(), map()) :: error_map()
  def invalid_payload(reason, details \\ %{}) do
    error(:invalid_payload, "Invalid NRPS response payload", Map.put(details, :reason, reason))
  end

  @spec transport_error(atom(), term(), boolean()) :: error_map()
  def transport_error(operation, error_term, retryable?) do
    error(
      :transport_error,
      "NRPS request transport error",
      %{
        operation: operation,
        error: inspect(error_term)
      },
      retryable?
    )
  end

  @spec http_error(atom(), non_neg_integer(), boolean()) :: error_map()
  def http_error(operation, status, retryable?) do
    error(
      :request_failed,
      "NRPS request failed",
      %{operation: operation, status: status},
      retryable?
    )
  end

  @spec max_pages_exceeded(pos_integer()) :: error_map()
  def max_pages_exceeded(max_pages) do
    error(:max_pages_exceeded, "NRPS traversal exceeded max_pages", %{max_pages: max_pages})
  end

  defp error(reason, msg, details, retryable \\ false) do
    %{reason: reason, msg: msg, details: details, retryable: retryable}
  end
end
