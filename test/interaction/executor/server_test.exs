defmodule Crux.Interaction.Executor.ServerTest do
  use ExUnit.Case, async: true
  doctest Crux.Interaction.Executor.Server

  import ExUnit.CaptureLog

  alias Crux.Interaction.Executor.Server

  # Since you can't seem to use defined functions in tests then
  defmodule Helpers do
    def start_anon(server, fun) do
      Server.start_child(server, {Kernel, :apply, [fun, []]})
    end
  end

  setup do
    [
      server:
        start_supervised!(%{
          id: Server,
          # Use the _test function to start an unnamed instance
          # -> multiple servers in parallel
          start: {Server, :start_link_test, []},
          type: :supervisor
        })
    ]
  end

  test "direct return value works", %{server: server} do
    assert {:ok, %{ok: :ok}} ==
             Helpers.start_anon(server, fn ->
               %{ok: :ok}
             end)
  end

  describe "not replying logs an error - " do
    test "returning nil", %{server: server} do
      parent = self()

      log =
        capture_log(fn ->
          assert {:error, :no_reply} ==
                   Helpers.start_anon(server, fn ->
                     send(parent, {:pid, self()})

                     nil
                   end)
        end)

      assert_receive {:pid, pid} when is_pid(pid)

      assert log =~ "Process #{inspect(pid)} exited without replying\."
    end

    test "crashing", %{server: server} do
      parent = self()

      log =
        capture_log(fn ->
          assert {:error, :no_reply} ==
                   Helpers.start_anon(server, fn ->
                     send(parent, {:pid, self()})
                     raise "Something went wrong! (This exception is intentionally thrown)"
                   end)
        end)

      assert_receive {:pid, pid} when is_pid(pid)

      assert log =~ "Process #{inspect(pid)} exited without replying\."
    end
  end

  describe "reply/2" do
    test "reply works", %{server: server} do
      assert {:ok, %{ok: :ok}} ==
               Helpers.start_anon(server, fn ->
                 :ok = Server.reply(server, %{ok: :ok})

                 nil
               end)
    end

    test "replying twice returns :error", %{server: server} do
      assert {:ok, %{ok: :ok}} ==
               Helpers.start_anon(server, fn ->
                 :ok = Server.reply(server, %{ok: :ok})
                 :error = Server.reply(server, %{ok: :ok})

                 nil
               end)
    end

    test "replying and returning errors", %{server: server} do
      assert {:ok, %{pid: pid}} =
               Helpers.start_anon(server, fn ->
                 :ok = Server.reply(server, %{pid: self()})

                 %{please: :crash}
               end)

      ref = Process.monitor(pid)

      assert_receive {:DOWN, ^ref, :process, _object, {error, _stacktrace}}

      assert "Expected a `nil` return after `reply/1` was used to send a reply early, but got: %{please: :crash}" ==
               error.message
    end
  end
end
