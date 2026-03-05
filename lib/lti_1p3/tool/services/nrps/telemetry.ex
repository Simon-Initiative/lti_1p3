defmodule Lti_1p3.Tool.Services.NRPS.Telemetry do
  @moduledoc """
  Telemetry emission helpers for Tool NRPS operations.
  """

  require Logger

  @spec request(map()) :: :ok
  def request(metadata) do
    :telemetry.execute([:lti_1p3, :tool, :nrps, :request], %{count: 1}, metadata)
    Logger.debug("tool_nrps.request #{inspect(metadata)}")
    :ok
  end

  @spec page(map()) :: :ok
  def page(metadata) do
    :telemetry.execute([:lti_1p3, :tool, :nrps, :page], %{count: 1}, metadata)

    :telemetry.execute(
      [:lti_1p3, :tool, :nrps, :membership],
      %{count: Map.get(metadata, :member_count, 0)},
      metadata
    )

    Logger.debug("tool_nrps.page #{inspect(metadata)}")
    :ok
  end

  @spec error(map()) :: :ok
  def error(metadata) do
    :telemetry.execute([:lti_1p3, :tool, :nrps, :error], %{count: 1}, metadata)
    Logger.error("tool_nrps.error #{inspect(metadata)}")
    :ok
  end
end
