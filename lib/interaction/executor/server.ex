defmodule Crux.Interaction.Executor.Server do
  @moduledoc false
  @moduledoc since: "0.1.0"
  use GenServer

  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # Only used for tests, so that they can run in parallel
  def start_link_test() do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def start_child(name \\ __MODULE__, mfa) do
    GenServer.call(name, {:start, mfa}, :infinity)
  end

  def reply(name \\ __MODULE__, message) do
    GenServer.call(name, {:reply, message})
  end

  @impl GenServer
  def init(nil) do
    Process.flag(:trap_exit, true)

    {:ok, Map.new()}
  end

  @impl GenServer
  def handle_call({:start, {m, f, a}}, from, state) do
    server = self()

    pid =
      spawn_link(fn ->
        apply(m, f, a)
        |> case do
          nil ->
            :ok

          message ->
            if reply(server, message) == :error do
              raise "Expected a `nil` return after `reply/1` was used to send a reply early, but got: #{inspect(message)}"
            end
        end
      end)

    new_state = Map.put(state, pid, from)

    {:noreply, new_state}
  end

  def handle_call({:reply, message}, {pid, _tag}, state) do
    case Map.pop(state, pid) do
      {nil, ^state} ->
        {:reply, :error, state}

      {from, new_state} ->
        GenServer.reply(from, {:ok, message})

        {:reply, :ok, new_state}
    end
  end

  @impl GenServer
  def handle_info({:EXIT, pid, _reason}, state) do
    new_state =
      case Map.pop(state, pid) do
        {nil, ^state} ->
          state

        {from, new_state} ->
          Logger.error(fn ->
            "Process #{inspect(pid)} exited without replying."
          end)

          GenServer.reply(from, {:error, :no_reply})

          new_state
      end

    {:noreply, new_state}
  end
end
