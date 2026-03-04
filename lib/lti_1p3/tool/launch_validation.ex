defmodule Lti_1p3.Tool.LaunchValidation do
  @moduledoc """
  Stage-based LTI launch validation pipeline.
  """

  alias Lti_1p3.Core.Telemetry
  alias Lti_1p3.Core.Validation.Deployment
  alias Lti_1p3.Core.Validation.Jwt
  alias Lti_1p3.Core.Validation.Message
  alias Lti_1p3.Core.Validation.Nonce
  alias Lti_1p3.Core.Validation.Registration
  alias Lti_1p3.Core.Validation.State
  alias Lti_1p3.Core.Validation.Timestamps
  alias Lti_1p3.Tool.Launch

  @type params() :: %{optional(String.t()) => String.t()}
  @type validate_opts() :: [raw_claims: boolean(), correlation_id: String.t()]

  @doc """
  Validates an incoming LTI 1.3 launch and returns a normalized launch struct.
  """
  @spec validate(params(), String.t() | nil, validate_opts()) ::
          {:ok, Launch.t()}
          | {:error, %{reason: atom(), stage: atom(), msg: String.t(), details: map()}}
  def validate(params, session_state, opts \\ []) do
    correlation_id = Keyword.get(opts, :correlation_id, UUID.uuid4())

    with :ok <- validate_state(session_state, params, correlation_id),
         {:ok, registration, _peeked_claims} <- resolve_registration(params, correlation_id),
         {:ok, id_token} <- fetch_id_token(params),
         {:ok, claims} <- validate_jwt(id_token, registration, correlation_id),
         :ok <- validate_timestamps(claims, correlation_id),
         {:ok, deployment_id} <- validate_deployment(registration, claims, correlation_id),
         {:ok, _message_type} <- validate_message(claims, correlation_id),
         :ok <- validate_nonce(claims, correlation_id) do
      launch = Launch.new(registration, claims, opts)
      Telemetry.emit_outcome(:ok, %{flow: :tool_launch, correlation_id: correlation_id})
      {:ok, %{launch | deployment_id: deployment_id}}
    else
      {:error, error} = result ->
        Telemetry.emit_outcome(:error, %{
          flow: :tool_launch,
          correlation_id: correlation_id,
          reason: error.reason,
          stage: error.stage
        })

        result
    end
  end

  defp validate_state(session_state, params, correlation_id) do
    case State.validate(session_state, Map.get(params, "state")) do
      :ok ->
        emit_stage_ok(:state, correlation_id)
        :ok

      {:error, error} ->
        emit_stage_error(:state, error, correlation_id)
    end
  end

  defp resolve_registration(params, correlation_id) do
    case Registration.resolve(params) do
      {:ok, registration, peeked_claims} ->
        emit_stage_ok(:registration, correlation_id)
        {:ok, registration, peeked_claims}

      {:error, error} ->
        emit_stage_error(:registration, error, correlation_id)
    end
  end

  defp validate_jwt(id_token, registration, correlation_id) do
    case Jwt.validate(id_token, registration) do
      {:ok, claims} ->
        emit_stage_ok(:jwt, correlation_id)
        {:ok, claims}

      {:error, error} ->
        emit_stage_error(:jwt, error, correlation_id)
    end
  end

  defp validate_timestamps(claims, correlation_id) do
    case Timestamps.validate(claims) do
      :ok ->
        emit_stage_ok(:timestamps, correlation_id)
        :ok

      {:error, error} ->
        emit_stage_error(:timestamps, error, correlation_id)
    end
  end

  defp validate_deployment(registration, claims, correlation_id) do
    case Deployment.validate(registration, claims) do
      {:ok, deployment_id} ->
        emit_stage_ok(:deployment, correlation_id)
        {:ok, deployment_id}

      {:error, error} ->
        emit_stage_error(:deployment, error, correlation_id)
    end
  end

  defp validate_message(claims, correlation_id) do
    case Message.validate(claims) do
      {:ok, message_type} ->
        emit_stage_ok(:message, correlation_id)
        {:ok, message_type}

      {:error, error} ->
        emit_stage_error(:message, error, correlation_id)
    end
  end

  defp validate_nonce(claims, correlation_id) do
    case Nonce.validate(claims, "validate_launch") do
      :ok ->
        emit_stage_ok(:nonce, correlation_id)
        :ok

      {:error, error} ->
        emit_stage_error(:nonce, error, correlation_id)
    end
  end

  defp fetch_id_token(params) do
    case Map.get(params, "id_token") do
      nil ->
        {:error, %{reason: :missing_param, stage: :jwt, msg: "Missing id_token", details: %{}}}

      id_token ->
        {:ok, id_token}
    end
  end

  defp emit_stage_ok(stage, correlation_id) do
    Telemetry.emit_stage(stage, :ok, %{flow: :tool_launch, correlation_id: correlation_id})
  end

  defp emit_stage_error(stage, error, correlation_id) do
    error = ensure_error_shape(error, stage)

    Telemetry.emit_stage(stage, :error, %{
      flow: :tool_launch,
      correlation_id: correlation_id,
      reason: error.reason,
      stage: error.stage
    })

    {:error, error}
  end

  defp ensure_error_shape(error, stage) do
    error
    |> Map.put_new(:stage, stage)
    |> Map.put_new(:details, %{})
  end
end
