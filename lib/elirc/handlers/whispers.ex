defmodule Elirc.Handler.Whisper do
  defmodule State do
    # "199.9.253.119:443",
    # "199.9.253.119:6667",
    # "199.9.253.119:80",
    # "199.9.253.120:443",
    # "199.9.253.120:6667",
    # "199.9.253.120:80"
    defstruct host: "199.9.253.119",
              port: 80,
              pass: "",
              nick: Application.get_env(:twitch, :username),
              user: Application.get_env(:twitch, :username),
              name: Application.get_env(:twitch, :username),
              channel: "",
              debug?: true,
              client: nil
  end

  def start_link(client, state \\ %State{}) do
    GenServer.start_link(__MODULE__, [%{state | client: client}])
  end

  def init([state]) do
    debug "Adding Whispers to client"
    IO.inspect state

    ExIrc.Client.add_handler state.client, self
    ExIrc.Client.connect! state.client, state.host, state.port
    {:ok, state}
  end

  def handle_info({:connected, server, port}, state) do
    debug "Connected to #{server}:#{port}"

    pass = Application.get_env(:twitch, :access_token)

    debug "Logging into #{state.nick} on #{server}:#{port}"

    IO.inspect state.client

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

  def handle_info(:logged_in, state) do
    request_twitch_capabilities(state.client)

    state.client |> ExIrc.Client.join(state.channel)

    debug "Joined channel: #{state.channel}"

    {:ok, state}
  end

  @doc """
  DUPLICTATE handler.login
  Request the CAP (capability) on the server

  ## Example
  cap_request(ExIrc.Client, ':twitch.tv/membership')
  """
  def cap_request(client, cap) do
    ExIrc.Client.cmd(client, ['CAP ', 'REQ ', cap])
  end

  @doc """
  DUPLICTATE handler.login
  Request twitch for capabilities
  """
  def request_twitch_capabilities(client) do
    # Request capabilities before joining the channel
    [':twitch.tv/membership',
     ':twitch.tv/commands',
     ':twitch.tv/tags']
      |> Enum.each(fn (cap) -> cap_request(client, cap) end)

    client
  end

  # Catch-all
  def handle_info(msg, state) do
    IO.inspect msg
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end