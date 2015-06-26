defmodule Elirc.MessageProxy.Supervisor do
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    poolboy_config = [
      {:name, {:local, pool_name()}},
      {:worker_module, Elirc.MessageProxy.Worker},
      {:size, 10},
      {:max_overflow, 10}
    ]

    children = [
      :poolboy.child_spec(pool_name(), poolboy_config, [client])
    ]

    options = [
      strategy: :one_for_one,
      name: Elirc.MessageProxy.Supervisor
    ]

    Supervisor.start_link(children, options)
 	end

  def pool_name() do
    :message_proxy_pool
  end

  def handle_info(info, state) do
    IO.inspect info
    {:noreply, state}
  end

  def terminate(reason, state) do
    IO.inspect reason
    :ok
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end