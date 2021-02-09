defmodule Lti_1p3.Platform.LoginHint do
  @enforce_keys [:value, :session_user_id]
  defstruct [:id, :value, :session_user_id, :context]

  @type t() :: %__MODULE__{
    id: integer(),
    value: String.t(),
    session_user_id: String.t(),
    context: String.t(),
  }

  def from(attrs) do
    struct(Lti_1p3.Platform.LoginHint, attrs)
  end

  def to_map(%Lti_1p3.Platform.LoginHint{} = login_hint) do
    login_hint
    |> Map.from_struct()
    |> Map.take(Lti_1p3.Platform.LoginHint.__struct__() |> Map.keys())
  end
end
