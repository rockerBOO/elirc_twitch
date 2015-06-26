defmodule Elirc.Message do
  defmodule State do
    defstruct channel: "",
              message: "",
              client: nil
  end

  def say(message, channel) do
    GenServer.start_link(message, channel)
  end

  @doc """
  Say message to channel

  ## Example
  say("Hello", "#test_channel", ExIrc.Client, true)
  """
  def say(message, channel, [client, _token]) do
    if noisy?(channel) do
      send_say(message, channel, client)
    else
      debug "Silenced... Say (#{channel}): #{message}"
    end
  end

  def noisy?(channel) do
    opts = Elirc.Channel.pid(channel)
      |> Elirc.Channel.state()
      |> Map.fetch!(:opts)

    opts.noisy?
  end

  @doc """
  Sends the message to the IRC server

  ## Example
  send_say("Hello", "#test_channel", ExIrc.Client)
  """
  def send_say(message, channel, client) do
    debug "Say (#{channel}): #{message}"

    client |> ExIrc.Client.msg(:privmsg, channel, message)
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end