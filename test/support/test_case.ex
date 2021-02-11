defmodule Lti_1p3.Test.TestCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Lti_1p3.Test.TestHelpers

    end
  end

  setup do
    {:ok, initial_state} = Lti_1p3.DataProviders.MemoryProvider.init()
    {:ok, genserver_pid} = Lti_1p3.DataProviders.MemoryProvider.start_link(initial_state)
    {:ok, process: genserver_pid}
  end
end
