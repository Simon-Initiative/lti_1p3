defmodule Lti_1p3.Platform.LoginHints do
  import Lti_1p3.Config

  alias Lti_1p3.Platform.LoginHint

  require Logger

  @doc """
  Gets a single login_hint by value
  Returns nil if the LoginHint does not exist.
  ## Examples
      iex> get_login_hint(123)
      %LoginHint{}
      iex> get_login_hint(456)
      nil
  """
  def get_login_hint_by_value(value), do: provider!().get_login_hint_by_value(value)

  @doc """
  Creates a login_hint for a user.
  ## Examples
      iex> create_login_hint(session_user_id)
      {:ok, %LoginHint{}}
  """
  def create_login_hint(session_user_id, context \\ nil), do:
    provider!().create_login_hint(%LoginHint{value: UUID.uuid4(), session_user_id: session_user_id, context: context})

  @doc """
  Removes all login_hints older than the configured login_hint_ttl_sec value
  """
  def cleanup_login_hint_store() do
    Logger.info("Cleaning up expired LTI 1.3 login_hints...")

    login_hint_ttl_sec = Lti_1p3.Config.get(:login_hint_ttl_sec)
    login_hint_expiry = Timex.now |> Timex.subtract(Timex.Duration.from_seconds(login_hint_ttl_sec))
    provider!().delete_expired_login_hints(login_hint_expiry)

    Logger.info("Login_hint cleanup complete.")
  end

end
