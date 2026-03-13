defmodule Lti_1p3.Platform.Services.AGS do
  @moduledoc """
  Platform-side LTI Assignment and Grading Services (AGS) orchestration.
  """

  alias Lti_1p3.Platform.Services.AGS.Context
  alias Lti_1p3.Platform.Services.AGS.Errors
  alias Lti_1p3.Platform.Services.AGS.LineItem
  alias Lti_1p3.Platform.Services.AGS.LineItems
  alias Lti_1p3.Platform.Services.AGS.Page
  alias Lti_1p3.Platform.Services.AGS.Result
  alias Lti_1p3.Platform.Services.AGS.Results
  alias Lti_1p3.Platform.Services.AGS.Score
  alias Lti_1p3.Platform.Services.AGS.ScopePolicy
  alias Lti_1p3.Platform.Services.AGS.Scores
  alias Lti_1p3.Platform.Services.AGS.Telemetry

  @type error_map :: Errors.error_map()

  @doc """
  Authorizes an AGS operation using token claims plus request context.
  """
  @spec authorize_operation(map(), atom(), Context.t() | map()) :: :ok | {:error, error_map()}
  def authorize_operation(claims, operation, context) when is_map(claims) do
    with {:ok, context} <- Context.coerce(context),
         :ok <- ScopePolicy.authorize_operation(claims, operation, context) do
      :ok
    end
  end

  @doc """
  Lists a single page of line items.
  """
  @spec list_line_items(Context.t() | map(), keyword()) ::
          {:ok, Page.t(LineItem.t())} | {:error, error_map()}
  def list_line_items(context, opts \\ []) do
    with_operation(context, :list_line_items, fn context -> LineItems.list(context, opts) end)
  end

  @doc """
  Creates a line item.
  """
  @spec create_line_item(Context.t() | map(), map()) ::
          {:ok, LineItem.t()} | {:error, error_map()}
  def create_line_item(context, attrs) do
    with_operation(context, :create_line_item, fn context -> LineItems.create(context, attrs) end)
  end

  @doc """
  Reads a line item.
  """
  @spec read_line_item(Context.t() | map(), String.t()) ::
          {:ok, LineItem.t()} | {:error, error_map()}
  def read_line_item(context, id_or_url) when is_binary(id_or_url) do
    with_operation(context, :read_line_item, fn context -> LineItems.read(context, id_or_url) end)
  end

  @doc """
  Updates a line item.
  """
  @spec update_line_item(Context.t() | map(), String.t(), map()) ::
          {:ok, LineItem.t()} | {:error, error_map()}
  def update_line_item(context, id_or_url, attrs) when is_binary(id_or_url) do
    with_operation(context, :update_line_item, fn context ->
      LineItems.update(context, id_or_url, attrs)
    end)
  end

  @doc """
  Deletes a line item.
  """
  @spec delete_line_item(Context.t() | map(), String.t()) :: :ok | {:error, error_map()}
  def delete_line_item(context, id_or_url) when is_binary(id_or_url) do
    with_operation(context, :delete_line_item, fn context ->
      LineItems.delete(context, id_or_url)
    end)
  end

  @doc """
  Ingests a score for an existing line item.
  """
  @spec post_score(Context.t() | map(), String.t(), Score.t() | map()) ::
          :ok | {:error, error_map()}
  def post_score(context, id_or_url, score) when is_binary(id_or_url) do
    with_operation(context, :post_score, fn context -> Scores.post(context, id_or_url, score) end)
  end

  @doc """
  Lists a single page of results for a line item.
  """
  @spec list_results(Context.t() | map(), String.t(), keyword()) ::
          {:ok, Page.t(Result.t())} | {:error, error_map()}
  def list_results(context, id_or_url, opts \\ []) when is_binary(id_or_url) do
    with_operation(context, :list_results, fn context ->
      Results.list(context, id_or_url, opts)
    end)
  end

  @doc """
  Returns required AGS scopes by operation.
  """
  @spec required_scopes(atom()) :: [String.t()]
  def required_scopes(:all), do: Lti_1p3.Services.AGS.ScopeSet.all_scopes()
  def required_scopes(operation), do: ScopePolicy.required_scopes(operation)

  defp with_operation(context_input, operation, callback) do
    with {:ok, context} <- Context.coerce(context_input),
         :ok <- emit_request(operation, context),
         :ok <- ScopePolicy.authorize_operation(context.claims, operation, context) do
      case callback.(context) do
        {:error, %{} = error} ->
          emit_error(operation, error)
          {:error, error}

        {:error, reason} ->
          error = Errors.provider_error(operation, reason)
          emit_error(operation, error)
          {:error, error}

        result ->
          result
      end
    else
      {:error, %{} = error} ->
        emit_error(operation, error)
        {:error, error}
    end
  end

  defp emit_request(operation, %Context{} = context) do
    Telemetry.request(%{
      operation: operation,
      deployment_id: context.deployment_id,
      context_id: context.context_id
    })

    :ok
  end

  defp emit_error(operation, %{reason: reason} = error)
       when reason in [:insufficient_scope, :invalid_deployment, :invalid_context] do
    Telemetry.denied(%{
      operation: operation,
      reason: reason,
      details: Map.get(error, :details, %{})
    })
  end

  defp emit_error(operation, error) do
    Telemetry.error(%{
      operation: operation,
      reason: Map.get(error, :reason),
      details: Map.get(error, :details, %{})
    })
  end
end
