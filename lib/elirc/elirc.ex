defmodule Elirc do
  use Supervisor

  defmodule Error do
    defexception reason: ""
  end

  def init([state]) do
    {:ok, state}
  end

  def start(_type, _args) do
    import Supervisor.Spec

    # Check if configurational environmental variables are set
    # check_environmental_state()

    Elirc.WebSocket.Router.run()

    # REST Twitch API
    {:ok, rest_client} = RestTwitch.Request.start()

    # Emoticons
    {:ok, emoticon_pid} = Elirc.Emoticon.start_link()

    IO.puts "Fetching and importing emoticons..."

    # GenServer.cast(emoticon_pid, "fetch_and_import")

    {:ok, client} = ExIrc.Client.start_link([])

    # {:ok, whisper_client} = ExIrc.Client.start_link([], [name: :whisper_irc])

    # whisper_server = %Elirc.Handler.Whisper.State{
    #   host: "199.9.253.120",
    #   channel: "#_elircbot_1435353964015",
    #   port: 80
    # }

    # Extensions
    {:ok, extension} = Elirc.Extension.start_link()

    # Twitch OAuth2 Access Token
    token = System.get_env("TWITCH_ACCESS_TOKEN")

    # Twitch Channels
    channels = Application.get_env(:twitch, :channels)

  	children = [
      # IRC Handlers
      worker(Elirc.Handler.Connection, [client]),
      worker(Elirc.Handler.Login, [client, channels]),
      worker(Elirc.Handler.Message, [client, token]),
      worker(Elirc.Handler.Names, [client]),
      # worker(Elirc.Handler.Whisper, [whisper_client, whisper_server]),

      # Channels Supervisor
      worker(Elirc.Channel.Supervisor, [client]),

      # Message Supervisors
      worker(Elirc.MessageQueue.Supervisor, [client, token]),
      worker(Elirc.MessagePool.Supervisor, [client, token]),
      worker(Elirc.CommandPool.Supervisor, [client, token]),
      worker(Elirc.SoundPool.Supervisor, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Elirc.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def check_environmental_state() do
    case System.get_env("TWITCH_USERNAME") do
      nil -> raise %Error{reason: "TWITCH_USERNAME is not set in the environment."}
      _ -> :ok
    end
  end

  def terminate(reason, state) do
    # Quit the channel and close the underlying client connection when the process is terminating
    ExIrc.Client.quit state.client, "Goodbye, cruel world."
    ExIrc.Client.stop! state.client
    :ok
  end
end