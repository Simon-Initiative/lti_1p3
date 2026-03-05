defmodule Lti_1p3.Tool.Services.AGS.Result do
  @moduledoc """
  AGS result payload.
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
