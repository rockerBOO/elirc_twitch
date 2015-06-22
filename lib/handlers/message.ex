defmodule Elirc.Handler.Message do
  def start_link(client, token) do
    GenServer.start_link(__MODULE__, [client, token])
  end

  def init([client, token]) do
    ExIrc.Client.add_handler client, self
    {:ok, %{client: client, token: token}}
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
  def handle_info(info, state) do
    {:noreply, state}
  end

  def terminate(reason, state) do
    :ok
  end
end