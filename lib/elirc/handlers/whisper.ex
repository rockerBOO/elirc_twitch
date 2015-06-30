defmodule Elirc.Handler.Whisper do
  defmodule State do
    defstruct host: "irc.twitch.tv",
              port: 6667,
              pass: "",
              nick: System.get_env("TWITCH_USERNAME"),
              user: System.get_env("TWITCH_USERNAME"),
              name: System.get_env("TWITCH_USERNAME"),
              channel: "",
              debug?: true,
              client: nil
  end

  def start_link(client, state \\ %State{}) do
    GenServer.start_link(__MODULE__, [%{state | client: client}], [name: __MODULE__])
  end

  def init([state]) do
    IO.puts "(w) adding to ExIrc.Client, self"
    IO.inspect state.client
    IO.inspect self

    ExIrc.Client.add_handler state.client, self
    ExIrc.Client.connect! state.client, state.host, state.port
    {:ok, state}
  end

  def handle_info({:connected, server, port}, state) do
    debug "(w) Connected to #{server}:#{port}"

    pass = System.get_env("TWITCH_ACCESS_TOKEN")

    debug "(w) Logging into #{state.nick}"

    IO.inspect state

    # Login to Twitch IRC
    ExIrc.Client.logon state.client, "oauth:" <> pass, state.nick,
      state.user, state.name

    {:noreply, state}
  end

  @doc """
  Handles logged_in requests
  """
  def handle_info(:logged_in, state) do
    debug "(w) Logged in to the server"

    debug "(w) Requesting capabilities on "
    IO.inspect state.client

    request_twitch_capabilities(state.client)
      |> join(state.channel)

    {:noreply, state}
  end

  @doc """
  Request twitch for capabilities
  """
  def request_twitch_capabilities(client) do
    # Request capabilities before joining the channel
    [ ':twitch.tv/membership',
      ':twitch.tv/commands',
      ':twitch.tv/tags']
      |> Enum.each(fn (cap) -> cap_request(client, cap) end)

    client
  end

  @doc """
  Join a list of channels

  ## Examples
  join(ExIrc.Client, [{"#rockerboo", %{noisy?: true}},
    {"#dansgaming", %{noisy?: false}}])
  """
  def join(client, channels) when is_list(channels) do
    debug "Joining channels #{IO.inspect channels}"

    channels
      |> Enum.map(&join(client, &1))

    debug "Reply to rockerboo!"


    client
  end

  @doc """
  Joins a channel, and starts the Elirc.Channel

  ## Examples
  join({"#rockerboo", %{noisy?: true}}, Exirc.Client)
  """
  def join(client, channel) do
    ExIrc.Client.join(client, channel)
    debug "(w) Joined channel: #{channel}"
  end

  @doc """
  Request the CAP (capability) on the server

  ## Example
  cap_request(ExIrc.Client, ':twitch.tv/membership')
  """
  def cap_request(client, cap) do
    ExIrc.Client.cmd(client, ['CAP ', 'REQ ', cap])
  end

  def handle_info({:disconnected, msg}, state) do
    # IO.inspect ExIrc.Client.state(state.client)
    debug "(w) :disconnected #{msg}"
    {:noreply, state}
  end

  # Catch-all
  def handle_info(msg, state) do
    debug "Received unknown messsage:"
    IO.inspect msg
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end