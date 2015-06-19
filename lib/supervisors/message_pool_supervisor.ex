defmodule Elirc.MessagePool.Supervisor do
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
	    poolboy_config = [
	      {:name, {:local, pool_name()}},
	      {:worker_module, Elirc.MessagePool.Worker},
	      {:size, 8},
	      {:max_overflow, 8}
	    ]

	    children = [
	      :poolboy.child_spec(pool_name(), poolboy_config, [client])
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
end