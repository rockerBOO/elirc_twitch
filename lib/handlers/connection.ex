defmodule Elirc.Handler.Connection do
  defmodule State do
    defstruct host: "irc.twitch.tv",
              port: 6667,
              pass: "",
              nick: Application.get_env(:twitch, :username),
              user: Application.get_env(:twitch, :username),
              name: Application.get_env(:twitch, :username),
              debug?: true,
              client: nil
  end

  def start_link(client, state \\ %State{}) do
    GenServer.start_link(__MODULE__, [%{state | client: client}])
  end

  def init([state]) do
    ExIrc.Client.add_handler state.client, self
    ExIrc.Client.connect! state.client, state.host, state.port
    {:ok, state}
  end

  def handle_info({:connected, server, port}, state) do
    debug "Connected to #{server}:#{port}"

    pass = Application.get_env(:twitch, :access_token)

    # Login to Twitch IRC
    ExIrc.Client.logon state.client, "oauth:" <> pass, state.nick,
      state.user, state.name

    {:noreply, state}
  end

  def handle_info(:disconnected, state) do
    # IO.inspect ExIrc.Client.state(state.client)
    debug ":disconnected"
    {:noreply, state}
  end

  # Catch-all
  def handle_info(msg, state) do
    # debug "Received unknown messsage:"
    # IO.inspect msg
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end