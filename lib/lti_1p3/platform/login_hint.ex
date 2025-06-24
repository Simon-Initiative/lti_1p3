defmodule Lti_1p3.Platform.LoginHint do
  @enforce_keys [:value, :session_user_id]
  defstruct [:id, :value, :session_user_id, :context]

  @type t() :: %__MODULE__{
          id: integer(),
          value: String.t(),
          session_user_id: String.t(),
          context: String.t() | map() | nil
        }
end
