defmodule Elirc.Handler.Message do
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:received, msg, user, channel}, client) do 
    {:ok, message} = Elirc.Message.start_link client, channel, msg
    
    {:noreply, client}
  end

  def handle_info(info, state) do
    {:noreply, state}
  end

  def terminate({stop, reason}, state) do
    IO.puts "Terminating on #{stop}"
    # IO.inspect reason
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end