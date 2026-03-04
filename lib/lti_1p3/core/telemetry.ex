defmodule Lti_1p3.Core.Telemetry do
  @moduledoc """
  Telemetry emitter for core validation flows.
  """

  require Logger

  @type metadata :: map()

  @spec emit_stage(atom(), :ok | :error, metadata()) :: :ok
  def emit_stage(stage, result, metadata \\ %{}) do
    metadata = Map.merge(%{stage: stage, result: result}, metadata)

    :telemetry.execute(
      [:lti_1p3, :core, :validation, :stage],
      %{count: 1},
      metadata
    )

    log_event(:stage, metadata)
    :ok
  end

  @spec emit_outcome(:ok | :error, metadata()) :: :ok
  def emit_outcome(result, metadata \\ %{}) do
    metadata = Map.merge(%{result: result}, metadata)

    :telemetry.execute(
      [:lti_1p3, :core, :validation, :outcome],
      %{count: 1},
      metadata
    )

    log_event(:outcome, metadata)
    :ok
  end

  defp log_event(type, metadata) do
    level = if metadata.result == :error, do: :warning, else: :info

    Logger.log(level, fn ->
      "lti_1p3 core_validation #{type}=#{type} result=#{metadata.result} stage=#{Map.get(metadata, :stage)} reason=#{Map.get(metadata, :reason)}"
    end)
  end
end
