defmodule Elirc do
  use Application

  @host  "irc.twitch.tv"
  @port  6667

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Elirc.NickGenerator, []),
      supervisor(Elirc.BotSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Elirc.Supervisor]

    {:ok, pid} = Supervisor.start_link(children, opts)

    Elirc.BotSupervisor.run(@host, @port)

    {:ok, pid}
  end

end
