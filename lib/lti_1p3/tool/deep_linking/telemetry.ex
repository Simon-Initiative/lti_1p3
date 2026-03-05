defmodule Lti_1p3.Tool.DeepLinking.Telemetry do
  @moduledoc false

  require Logger

  @spec emit_request(:ok | :error, map()) :: :ok
  def emit_request(result, metadata \\ %{}) do
    emit([:lti_1p3, :tool, :deep_linking, :request], result, metadata)
  end

  @spec emit_response(:ok | :error, map()) :: :ok
  def emit_response(result, metadata \\ %{}) do
    emit([:lti_1p3, :tool, :deep_linking, :response], result, metadata)
  end

  defp emit(event, result, metadata) do
    metadata = Map.merge(%{result: result}, metadata)

    :telemetry.execute(event, %{count: 1}, metadata)

    level = if result == :error, do: :warning, else: :info

    Logger.log(level, fn ->
      "lti_1p3 tool_deep_linking event=#{Enum.join(Enum.map(event, &to_string/1), ".")} result=#{result} reason=#{Map.get(metadata, :reason)} issuer=#{Map.get(metadata, :issuer)} client_id=#{Map.get(metadata, :client_id)} item_count=#{Map.get(metadata, :item_count)}"
    end)

    :ok
  end
end
