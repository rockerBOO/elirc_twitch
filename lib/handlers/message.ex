defmodule Elirc.Handler.Message do
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:received, msg, user, channel}, state) do 
    pool_name = Elirc.MessagePool.Supervisor.pool_name()

    :poolboy.transaction(
      pool_name,
      fn(pid) -> :gen_server.call(pid, [channel, user, msg]) end,
      :infinity
    )

    {:noreply, state}
  end

  # Catch all
  def handle_info(info, client) do
    {:noreply, client}
  end

  def terminate(reason, client) do
    :ok
  end
end