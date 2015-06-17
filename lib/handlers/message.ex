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

  # Catch all
  def handle_info(info, client) do
    {:noreply, client}
  end

  def terminate(reason, client) do
    :ok
  end
end