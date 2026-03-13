defmodule Lti_1p3.Platform.Services.AGS.LineItem do
  @moduledoc """
  Platform AGS line item payload.
  """

  @derive Jason.Encoder
  @enforce_keys [:id, :scoreMaximum, :label]
  defstruct [:id, :scoreMaximum, :label, :resourceId, :tag, :resourceLinkId]

  @type t() :: %__MODULE__{
          id: String.t(),
          scoreMaximum: float() | integer(),
          label: String.t(),
          resourceId: String.t() | integer() | nil,
          tag: String.t() | nil,
          resourceLinkId: String.t() | nil
        }
end
