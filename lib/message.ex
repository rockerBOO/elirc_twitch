defmodule Elirc.Message do
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:received, message, user, channel}, client) do 
    debug message
    debug channel
    debug user

    message 
      |> Elirc.Bot.Command.find_command 
      |> Elirc.Bot.Command.run client, channel
    
    {:noreply, client}
  end

  def handle_info(info, state) do
    IO.inspect info
    {:noreply, state}
  end

  def handle_info(info) do
    IO.inspect info
  end

  def terminate({stop, reason}, state) do
    IO.puts "Terminating on #{stop}"
    # IO.inspect reason
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end