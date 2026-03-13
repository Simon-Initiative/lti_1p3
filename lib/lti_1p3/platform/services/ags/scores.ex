defmodule Lti_1p3.Platform.Services.AGS.Scores do
  @moduledoc """
  Platform AGS score ingestion operations.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Platform.Services.AGS.Context
  alias Lti_1p3.Platform.Services.AGS.Errors
  alias Lti_1p3.Platform.Services.AGS.Score
  alias Lti_1p3.Platform.Services.AGS.Telemetry

  @spec post(Context.t(), String.t(), Score.t() | map()) :: :ok | {:error, Errors.error_map()}
  def post(%Context{} = context, id_or_url, score) when is_binary(id_or_url) do
    with {:ok, score} <- validate_score(score),
         :ok <-
           provider!().create_ags_score(
             context.deployment_id,
             context.context_id,
             id_or_url,
             score
           ) do
      Telemetry.score(%{operation: :post_score, line_item_id: id_or_url, user_id: score.userId})
      :ok
    else
      {:error, %{} = error} ->
        {:error, error}

      {:error, reason} ->
        {:error, Errors.normalize_provider_error(:post_score, reason, id_or_url)}
    end
  end

  defp validate_score(%Score{} = score), do: {:ok, score}

  defp validate_score(score_attrs) when is_map(score_attrs) do
    attrs = Enum.into(score_attrs, %{})
    required_fields = [:timestamp, :activityProgress, :gradingProgress, :userId]

    if Enum.all?(required_fields, &present?(Map.get(attrs, &1))) do
      {:ok,
       struct(Score, %{
         timestamp: Map.get(attrs, :timestamp),
         scoreGiven: Map.get(attrs, :scoreGiven),
         scoreMaximum: Map.get(attrs, :scoreMaximum),
         comment: Map.get(attrs, :comment),
         activityProgress: Map.get(attrs, :activityProgress),
         gradingProgress: Map.get(attrs, :gradingProgress),
         userId: Map.get(attrs, :userId)
       })}
    else
      {:error, Errors.invalid_attrs(:post_score, :missing_required_score_fields)}
    end
  end

  defp validate_score(_),
    do: {:error, Errors.invalid_attrs(:post_score, :invalid_score_shape)}

  defp present?(value) when is_binary(value), do: String.trim(value) != ""
  defp present?(nil), do: false
  defp present?(_value), do: true
end
