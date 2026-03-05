defmodule Lti_1p3.Tool.Services.AGS.Telemetry do
  @moduledoc """
  Telemetry emission helpers for Tool AGS operations.
  """

  require Logger

  @spec request(map()) :: :ok
  def request(metadata) do
    :telemetry.execute([:lti_1p3, :tool, :ags, :request], %{count: 1}, metadata)
    Logger.debug("tool_ags.request #{inspect(metadata)}")
    :ok
  end

  @spec line_item(map()) :: :ok
  def line_item(metadata) do
    :telemetry.execute([:lti_1p3, :tool, :ags, :line_item], %{count: 1}, metadata)
    Logger.debug("tool_ags.line_item #{inspect(metadata)}")
    :ok
  end

  @spec result(map()) :: :ok
  def result(metadata) do
    :telemetry.execute([:lti_1p3, :tool, :ags, :result], %{count: 1}, metadata)
    Logger.debug("tool_ags.result #{inspect(metadata)}")
    :ok
  end

  @spec scope_denied(map()) :: :ok
  def scope_denied(metadata) do
    :telemetry.execute([:lti_1p3, :tool, :ags, :scope_denied], %{count: 1}, metadata)
    Logger.warning("tool_ags.scope_denied #{inspect(metadata)}")
    :ok
  end

  @spec error(map()) :: :ok
  def error(metadata) do
    :telemetry.execute([:lti_1p3, :tool, :ags, :error], %{count: 1}, metadata)
    Logger.error("tool_ags.error #{inspect(metadata)}")
    :ok
  end
end
