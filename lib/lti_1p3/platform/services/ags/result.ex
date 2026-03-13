defmodule Lti_1p3.Platform.Services.AGS.Result do
  @moduledoc """
  Platform AGS result payload.
  """

  @derive Jason.Encoder
  defstruct [:userId, :resultScore, :resultMaximum, :comment]

  @type t() :: %__MODULE__{
          userId: String.t() | nil,
          resultScore: float() | integer() | nil,
          resultMaximum: float() | integer() | nil,
          comment: String.t() | nil
        }
end
