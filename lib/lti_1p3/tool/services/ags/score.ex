defmodule Lti_1p3.Tool.Services.AGS.Score do
  @moduledoc """
  AGS score payload.
  """

  @derive Jason.Encoder
  @enforce_keys [:timestamp, :activityProgress, :gradingProgress, :userId]
  defstruct [
    :timestamp,
    :scoreGiven,
    :scoreMaximum,
    :comment,
    :activityProgress,
    :gradingProgress,
    :userId
  ]

  @type t() :: %__MODULE__{
          timestamp: String.t(),
          scoreGiven: float() | integer() | nil,
          scoreMaximum: float() | integer() | nil,
          comment: String.t() | nil,
          activityProgress: String.t(),
          gradingProgress: String.t(),
          userId: String.t()
        }
end
