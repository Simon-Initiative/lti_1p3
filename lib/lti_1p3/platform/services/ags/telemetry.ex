defmodule Lti_1p3.Platform.Services.AGS.Telemetry do
  @moduledoc """
  Telemetry emission helpers for Platform AGS operations.
  """

  require Logger

  @spec request(map()) :: :ok
  def request(metadata) do
    :telemetry.execute([:lti_1p3, :platform, :ags, :request], %{count: 1}, metadata)
    Logger.debug("platform_ags.request #{inspect(metadata)}")
    :ok
  end

  @spec denied(map()) :: :ok
  def denied(metadata) do
    :telemetry.execute([:lti_1p3, :platform, :ags, :denied], %{count: 1}, metadata)
    Logger.warning("platform_ags.denied #{inspect(metadata)}")
    :ok
  end

  @spec line_item(map()) :: :ok
  def line_item(metadata) do
    :telemetry.execute([:lti_1p3, :platform, :ags, :line_item], %{count: 1}, metadata)
    Logger.debug("platform_ags.line_item #{inspect(metadata)}")
    :ok
  end

  @spec score(map()) :: :ok
  def score(metadata) do
    :telemetry.execute([:lti_1p3, :platform, :ags, :score], %{count: 1}, metadata)
    Logger.debug("platform_ags.score #{inspect(metadata)}")
    :ok
  end

  @spec result(map()) :: :ok
  def result(metadata) do
    :telemetry.execute([:lti_1p3, :platform, :ags, :result], %{count: 1}, metadata)
    Logger.debug("platform_ags.result #{inspect(metadata)}")
    :ok
  end

  @spec error(map()) :: :ok
  def error(metadata) do
    :telemetry.execute([:lti_1p3, :platform, :ags, :error], %{count: 1}, metadata)
    Logger.error("platform_ags.error #{inspect(metadata)}")
    :ok
  end
end
