defmodule Elirc.Users do
  def start_link() do
    GenServer.start_link(__MODULE__, [], [])
  end


  def init([]) do

    {:ok, []}
  end


  def start(_type, _args) do
    import Supervisor.Spec

  	children = [
      # Handles connection actions in IRC
      # worker(Elirc.User, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :simple_one_for_one, name: Elirc.Users.Supervisor]
    Supervisor.start_link(children, opts)
  end
end