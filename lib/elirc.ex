defmodule Elirc do
  use Supervisor

  def init([state]) do
    {:ok, state}
  end

  def start(_type, _args) do
    import Supervisor.Spec

    {:ok, rest_client} = RestTwitch.Request.start
    {:ok, token_rest_client} = RestTwitch.TokenRequest.start

    # Twitch OAuth2 Access Token
    token = System.get_env("TWITCH_ACCESS_TOKEN")

    {:ok, client} = ExIrc.Client.start_link [debug: true]

    # Twitch Channels
    channels = Application.get_env(:twitch, :channels) |> String.split(" ")

  	children = [
      # Handles connection actions in IRC
      worker(Elirc.Handler.Connection, [client]),
      # Handles Login actions
      # worker(Elirc.Handler.Login, [client, ["#rockerboo", "#jonbams", "#lirik", "#itmejp"]]),
      worker(Elirc.Handler.Login, [client, channels]),
      # worker(Elirc.Handler.Join, [client]),
      worker(Elirc.Handler.Message, [client, token]),
      worker(Elirc.Handler.Names, [client]),
      worker(Elirc.Channel.Supervisor, [client]),
      worker(Elirc.MessagePool.Supervisor, [client, token])
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