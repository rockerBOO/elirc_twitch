defmodule Elirc do
  use Supervisor

  def init([state]) do
    {:ok, state}
  end

  def start(_type, _args) do
    import Supervisor.Spec

    {:ok, rest_client} = RestTwitch.Request.start
    {:ok, client} = ExIrc.Client.start_link [debug: true]

  	children = [
      # Handles connection actions in IRC
      worker(Elirc.Handler.Connection, [client]),
      # Handles Login actions
      # worker(Elirc.Handler.Login, [client, ["#rockerboo", "#jonbams", "#lirik", "#itmejp"]]),
      worker(Elirc.Handler.Login, [client, [
          "#rockerboo", 
          # "#trumpsc", "#adren_tv", "#mushisgosu", "#summit1g",
          # "#sodapoppin", "#resolut1ontv", "#zeeoon", "#lebledart"
        ]]),
      # worker(Elirc.Handler.Join, [client]),
      worker(Elirc.Handler.Message, [client]),
      worker(Elirc.Handler.Names, [client]),
      worker(Elirc.Channel.Supervisor, [client]),
      worker(Elirc.MessagePool.Supervisor, [client])
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