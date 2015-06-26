defmodule Elirc.MessagePool.Supervisor do
  def start_link(client, token) do
    GenServer.start_link(__MODULE__, [client, token])
  end

  def init([client, token]) do
	    poolboy_config = [
	      {:name, {:local, pool_name()}},
	      {:worker_module, Elirc.MessagePool.Worker},
	      {:size, 8},
	      {:max_overflow, 8}
	    ]

	    children = [
	      :poolboy.child_spec(pool_name(), poolboy_config, [client, token])
	    ]

	    options = [
	      strategy: :one_for_one,
	      name: Elirc.MessagePool.Supervisor
	    ]

	    Supervisor.start_link(children, options)
 	end

  def pool_name() do
    :message_pool
  end

  def terminate(reason, state) do
    IO.inspect reason
    :ok
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end