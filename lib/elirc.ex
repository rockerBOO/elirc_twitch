defmodule Elirc do
  use Supervisor

  def init([state]) do
    {:ok, state}
  end

  def start(_type, _args) do
    import Supervisor.Spec

    {:ok, client} = ExIrc.Client.start_link [debug: true]

  	children = [
      # Handles connection actions in IRC
      worker(Elirc.Handler.Connection, [client]),
      # Handles Login actions
      worker(Elirc.Handler.Login, [client, ["#rockerboo", "#slothmonster", "#dansgaming", "#tsm_bjergsen"]]),
      # worker(Elirc.Handler.Join, [client]),
      worker(Elirc.Handler.Message, [client]),
      worker(Elirc.Handler.User, [client]),
      worker(Elirc.Users.Supervisor, [client])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Elirc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def terminate(reason, state) do
    IO.puts reason
  end
end