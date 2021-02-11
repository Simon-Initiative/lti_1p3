defmodule Lti_1p3.Platform.LoginHintsTest do
  use Lti_1p3.Test.TestCase

  alias Lti_1p3.DataProviders.MemoryProvider
  alias Lti_1p3.Platform.LoginHints

  describe "lti 1.3 login_hints" do
    setup [:create_user]

    test "should get existing login_hint", %{user: user} do
      {:ok, login_hint} = LoginHints.create_login_hint(user.id)

      fetched_login_hint = LoginHints.get_login_hint_by_value(login_hint.value)
      assert fetched_login_hint.value == login_hint.value
      assert fetched_login_hint.session_user_id == user.id
      assert fetched_login_hint.context == nil
    end

    test "should create new login_hint with specified user and context", %{user: user} do
      {:ok, login_hint} = LoginHints.create_login_hint(user.id, "some-context")

      fetched_login_hint = LoginHints.get_login_hint_by_value(login_hint.value)
      assert fetched_login_hint.value == login_hint.value
      assert fetched_login_hint.session_user_id == user.id
      assert fetched_login_hint.context == "some-context"
    end

    test "should cleanup expired login_hints", %{user: user} do
      {:ok, login_hint} = LoginHints.create_login_hint(user.id)

      # verify the login_hint exists before cleanup
      fetched_login_hint = LoginHints.get_login_hint_by_value(login_hint.value)
      assert fetched_login_hint == login_hint

      # fake the nonce was created a day + 1 hour ago
      a_day_before = Timex.now |> Timex.subtract(Timex.Duration.from_hours(25))
      Agent.update(MemoryProvider, fn state ->
        %{state | login_hints: state.login_hints |> Map.put(login_hint.value, Map.put(login_hint, :inserted_at, a_day_before))}
      end)

      # run cleanup
      LoginHints.cleanup_login_hint_store()

      assert LoginHints.get_login_hint_by_value(login_hint.value) == nil
    end
  end

  defp create_user(_context) do
    user = lti_1p3_user()

    %{user: user}
  end

end
