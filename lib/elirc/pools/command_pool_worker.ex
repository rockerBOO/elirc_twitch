defmodule Elirc.CommandPool.Worker do
  alias Elirc.Command

  @doc """

  ## Example
  start_link([ExIrc.Client, "TWITCH_ACCESS_TOKEN"])
  """
  def start_link([client, token, commands, aliases]) do
    GenServer.start_link(__MODULE__, [client, token, commands, aliases], [])
  end

  def init([client, token, commands, aliases]) do
    {:ok, %{client: client, token: token, commands: commands, aliases: aliases}}
  end

  # Handles calls to run a command
  def handle_call({:run, {cmd, channel, user}}, _from, state) do
    {:reply, Command.route(cmd, channel, user, state), state}
  end
end