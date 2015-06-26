defmodule Elirc.Users.Supervisor do
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
      worker(Elirc.Channel.Users, [client]),
    ]

    opts = [strategy: :simple_one_for_one, 
      name: __MODULE__]

    supervise(children, opts)
  end
end