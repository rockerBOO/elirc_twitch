defmodule Elirc.MessagePool.Worker do
  def start_link(client) do
    GenServer.start_link(__MODULE__, client, [])
  end

  def init(client) do
    {:ok, client}
  end

  def handle_call([channel, user, message], _from, client) do
    process_command(message, channel, client)

    {:reply, :ok, client}
  end

  def process_command(message, channel, client) do
    {:ok, command} = Elirc.Bot.Command.start_link(client, channel)

    GenServer.cast(command, {:process, message})
  end
end