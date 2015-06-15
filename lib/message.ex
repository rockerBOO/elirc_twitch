defmodule Elirc.Message do
  defmodule State do
    defstruct channel: "",
              message: "",
              client: nil
  end

	def start_link(client, channel, message) do
    GenServer.start_link(__MODULE__, [client, channel, message])
  end

  def init([client, channel, message]) do 
    state = %{client: client, channel: channel, message: message}

    process_command(message, channel, client)

    {:ok, state}
  end

  def process_command(message, channel, client) do
    {:ok, command} = Elirc.Bot.Command.start_link(client, channel)

    GenServer.cast(command, {:process, message})
  end
end