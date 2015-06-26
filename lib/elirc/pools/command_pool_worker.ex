defmodule Elirc.CommandPool.Worker do
  alias Elirc.Command

  @doc """

  ## Example
  start_link([ExIrc.Client, "TWITCH_ACCESS_TOKEN"])
  """
  def start_link([client, token]) do
    GenServer.start_link(__MODULE__, [client, token], [])
  end

  def init([client, token]) do
    {:ok, %{client: client, token: token}}
  end

  # Handles calls to run a command
  def handle_call({:run, [cmd: cmd, channel: channel]}, _from, state) do
    {:reply, Command.cmd(cmd, channel, state.token, state.client), state}
  end
end