defmodule Elirc.MessagePool.Worker do
  def start_link([client, token]) do
    GenServer.start_link(__MODULE__, [client, token], [])
  end

  def init([client, token]) do
    {:ok, [client, token]}
  end

  def handle_call([channel, user, message], _from, state) do
    process_command(message, channel, state)

    {:reply, :ok, state}
  end

  def process_command(message, channel, state = [client, token]) do
    {:ok, command} = Elirc.Bot.Command.start_link(client, token, channel)

    GenServer.cast(command, {:process, message})
  end
end