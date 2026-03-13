defmodule Lti_1p3.Platform.Services.AGS.Context do
  @moduledoc """
  Request context for platform AGS operations.
  """

  alias Lti_1p3.Platform.Services.AGS.Errors
  alias Lti_1p3.Services.AGS.ScopeSet

  @enforce_keys [:deployment_id, :context_id, :claims, :scopes]
  defstruct [:deployment_id, :context_id, :claims, :scopes, :client_id]

  @type t() :: %__MODULE__{
          deployment_id: String.t(),
          context_id: String.t(),
          claims: map(),
          scopes: [String.t()],
          client_id: String.t() | nil
        }

  @spec coerce(t() | map()) :: {:ok, t()} | {:error, Errors.error_map()}
  def coerce(%__MODULE__{} = context), do: {:ok, context}

  def coerce(context) when is_map(context) do
    claims = map_get(context, :claims, %{})
    deployment_id = map_get(context, :deployment_id)
    context_id = map_get(context, :context_id)
    client_id = map_get(context, :client_id)

    scopes =
      case map_get(context, :scopes) do
        nil -> ScopeSet.parse_scope_string(Map.get(claims, "scope"))
        value -> ScopeSet.parse_scope_string(value)
      end

    with :ok <- ensure_present(deployment_id, :missing_deployment_id),
         :ok <- ensure_present(context_id, :missing_context_id),
         :ok <- ensure_map(claims) do
      {:ok,
       %__MODULE__{
         deployment_id: deployment_id,
         context_id: context_id,
         claims: claims,
         scopes: scopes,
         client_id: client_id
       }}
    end
  end

  def coerce(_), do: {:error, Errors.invalid_context_shape()}

  defp ensure_map(claims) when is_map(claims), do: :ok
  defp ensure_map(_), do: {:error, Errors.invalid_context_shape()}

  defp ensure_present(value, _reason) when is_binary(value) and byte_size(value) > 0, do: :ok
  defp ensure_present(_value, reason), do: {:error, Errors.invalid_context_input(reason)}

  defp map_get(map, key, default \\ nil) do
    Map.get(map, key, Map.get(map, Atom.to_string(key), default))
  end
end
