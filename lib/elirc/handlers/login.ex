defmodule Elirc.Handler.Login do
  alias Beaker.Counter
  alias Beaker.TimeSeries
  alias Elirc.Channel.Supervisor, as: ChannelSupervisor

  @doc """
  Starts the login handler

  ## Example
  Login.start_link(ExIrc.Client, [{"#test_channel", %{noisy?: true}])
  """
  @spec start_link(client :: pid, channels :: list()) :: {:ok, pid} | {:error, term}
  def start_link(client, channels) do
    GenServer.start_link(__MODULE__, [client, channels])
  end

  def init([client, channels]) do
    ExIrc.Client.add_handler client, self
    {:ok, {client, channels}}
  end

  def terminate(reason, _state) do
    IO.inspect reason
    :ok
  end

  @doc """
  Request the CAP (capability) on the server

  ## Example
  cap_request(ExIrc.Client, ':twitch.tv/membership')
  """
  def cap_request(client, cap) do
    ExIrc.Client.cmd(client, ['CAP ', 'REQ ', cap])
  end

  @doc """
  Handles logged_in requests
  """
  def handle_info(:logged_in, state = {client, channels}) do
    debug "Logged in to server"

    request_twitch_capabilities(client)
      |> join(channels)

    {:noreply, state}
  end

  @doc """
  Request twitch for capabilities
  """
  def request_twitch_capabilities(client) do
    # Request capabilities before joining the channel
    [':twitch.tv/membership',
      ':twitch.tv/commands']
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
    channels
      |> Enum.map(&join(client, &1))

    client
  end

  @doc """
  Joins a channel, and starts the Elirc.Channel

  ## Examples
  join({"#rockerboo", %{noisy?: true}}, Exirc.Client)
  """
  def join(client, {channel, channel_details}) do
    ExIrc.Client.join(client, channel)

    ChannelSupervisor.new(channel, channel_details)

    start_recurring(client, channel)

    start_metrics(channel)

    debug "Joined channel: #{channel}"
  end

  @doc """
  Start the recurring messages for the channel

  ## Example
  start_recurring(ExIrc.Client, "#test_channel")
  """
  def start_recurring(client, channel) do
    msg = "Hello! I am a human trapped in an IRC Channel. Please send treats. Thanks, sweetly."
    Quantum.add_job("*/30 * * * *", fn -> Elirc.Message.say(msg, channel, client) end)
  end

  @doc """
  Start the recurring messages for the channel

  ## Example
  start_recurring(ExIrc.Client, "#test_channel")
  """
  def start_metrics(channel) do
    # Every 1 min, flush channel metric count
    Quantum.add_job("*/1 * * * *", fn ->
      Elirc.Handler.Login.process_metrics(channel)
    end)
  end

  @doc """
  Process metrics for the channel

  ## Example
  process_metrics("#test_channel")
  """
  def process_metrics(channel) do
    debug "Processing Metrics for #{channel}"

    # Counter.get(channel)
    #   |> TimeSeries.sample(channel)
    #   |> Counter.set(0)

    Beaker.TimeSeries.get(channel)
      |> IO.inspect

    count = Counter.get(channel)

    TimeSeries.sample(channel, count)

    Counter.set(channel, 0)
  end

  @doc """
  Drops unknown messages
  """
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end