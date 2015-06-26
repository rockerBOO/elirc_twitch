defmodule Elirc.Handler.Join do
  @moduledoc """
  This is an example event handler that greets users when they join a channel
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:mode, [channel, op, user]}, state) do
    IO.inspect channel
    IO.inspect op
    IO.inspect user

    {:noreply, state}
  end

  # # Catch-all for messages you don't care about
  def handle_info(msg, state) do
    IO.inpsect msg

    # debug msg
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end