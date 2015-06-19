defmodule Elirc.Handler.Login do
  @moduledoc """
  """
  def start_link(client, channels) do
    GenServer.start_link(__MODULE__, [client, channels])
  end

  def init([client, channels]) do
    ExIrc.Client.add_handler client, self
    {:ok, {client, channels}}
  end

  def terminate(reason, state) do
    IO.inspect reason
    :ok
  end

  @doc """
  Request the CAP (capability) on the server
  """
  def cap_request(client, cap) do
    ExIrc.Client.cmd(client, ['CAP ', 'REQ ', cap])
  end

  def handle_info(:logged_in, state = {client, channels}) do
    debug "Logged in to server"

    # Request capabilities before joining the channel 
    [':twitch.tv/membership', 
      ':twitch.tv/commands']
     |> Enum.each(fn (cap) -> cap_request(client, cap) end)

    channels |> Enum.map(&join(&1, client))
    {:noreply, state}
  end

  def join(channel, client) do
    ExIrc.Client.join(client, channel)

    Elirc.Channel.Supervisor.new_channel(client, channel)
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end