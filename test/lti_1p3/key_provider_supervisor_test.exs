defmodule Lti_1p3.KeyProviderSupervisorTest do
  use ExUnit.Case, async: false

  alias Lti_1p3.KeyProviderSupervisor
  alias Lti_1p3.KeyProviders.MemoryKeyProvider

  describe "start_link/1" do
    test "starts supervisor with default options" do
      {:ok, pid} = KeyProviderSupervisor.start_link()
      assert Process.alive?(pid)

      # Verify the key provider is running
      children = Supervisor.which_children(pid)
      assert length(children) == 1

      [{MemoryKeyProvider, child_pid, :worker, [MemoryKeyProvider]}] = children
      assert Process.alive?(child_pid)

      Supervisor.stop(pid)
    end

    test "starts supervisor with custom options" do
      opts = [
        key_provider: MemoryKeyProvider,
        refresh_interval: 300,
        cache_ttl: 600
      ]

      {:ok, pid} = KeyProviderSupervisor.start_link(opts)
      assert Process.alive?(pid)

      children = Supervisor.which_children(pid)
      assert length(children) == 1

      Supervisor.stop(pid)
    end

    test "restarts key provider if it crashes" do
      {:ok, supervisor_pid} = KeyProviderSupervisor.start_link(refresh_interval: 0)

      [{MemoryKeyProvider, original_pid, :worker, [MemoryKeyProvider]}] =
        Supervisor.which_children(supervisor_pid)

      # Kill the key provider
      Process.exit(original_pid, :kill)

      # Wait for restart
      Process.sleep(100)

      [{MemoryKeyProvider, new_pid, :worker, [MemoryKeyProvider]}] =
        Supervisor.which_children(supervisor_pid)

      assert Process.alive?(new_pid)
      assert new_pid != original_pid

      Supervisor.stop(supervisor_pid)
    end
  end
end
