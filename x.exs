
defmodule Sup do
  use Supervisor

  def start_link(client) do
    Supervisor.start_link(__MODULE__, [client], [name: Elirc.Users.Supervisor])
  end

  def start_child(supervisor, child_args_spec) do
    Supervisor.start_child(supervisor, child_args_spec)
  end

  def init([client]) do
    import Supervisor.Spec

    children = [
      # Handles connection actions in IRC
      worker(Users, [client]),
    ]

    opts = [strategy: :simple_one_for_one, 
      name: __MODULE__]

    supervise(children, opts)
  end
end

defmodule Users do
  def start_link(client) do
    IO.puts "tests start_link"
    GenServer.start_link(__MODULE__, client, [])
  end

  def init(client) do
    {:ok, client}
  end
end

defmodule UserHandler do
  def new_channel(channel) do
    {:ok, users_pid} = Sup.start_child(Elirc.Users.Supervisor, [])
  
    users_pid
  end
end

supervisor = Sup.start_link(:client)

UserHandler.new_channel("#rockerboo")