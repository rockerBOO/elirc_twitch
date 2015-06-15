require Logger

defmodule Elirc.Bot do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, socket} = Socket.TCP.connect(state.host, state.port, packet: :line)
    {:ok, %{state | sock: socket}, 0}
  end

# 80 [info]  19 :bentanweihao!~bentanwei@27.96.106.134PRIVMSG#elixir-lang:makeswritinglooklikeawalkinthepark
# [":bentanweihao!~bentanwei@27.96.106.134", "PRIVMSG", "#elixir-lang", ":makes",

  # "message"
  def parse_message(message, _socket) when is_binary(message) do
    message 
      |> String.split
      |> parse_message(_socket) 
  end

  # ["PING", message]
  def parse_message(["PING", server], socket) do 
    pong = "PONG #{server}\r\n"
    socket |> Socket.Stream.send!(pong)
    pong
  end

  # 
  def parse_message([who, "PRIVMSG", channel | message], _socket) do 
    [":" <> head | tail] = message

    message = Enum.join([head | tail], " ")
    message = %{who: parse_sender(who), message: message}

    message
  end

  # [message, listed, out]
  def parse_message(message, _socket) do
    message
      |> Enum.join(" ")
  end

  def parse_sender(who) do
    ":" <> who = who
    who |> String.split("!") |> hd 
  end

  def handle_info(:timeout, state) do
    state |> do_join_channel |> do_listen
    { :noreply, state }
  end

  defp do_join_channel(%{sock: sock} = state) do
    pass = System.get_env "TWITCH_CHAT_KEY"

    sock |> Socket.Stream.send!("PASS #{pass}\r\n")
    sock |> Socket.Stream.send!("NICK #{state.nick}\r\n")
    sock |> Socket.Stream.send!("USER #{state.nick} #{state.host} #{state.nick} #{state.nick}\r\n")
    sock |> Socket.Stream.send!("JOIN #{state.chan}\r\n")
    state
  end

  defp do_listen(%{sock: sock} = state) do
    case state.sock |> Socket.Stream.recv! do
      data when is_binary(data) ->
        IO.inspect data
        parse_message(data, state.sock) 
          |> Elirc.Bot.Command.find_command
          |> Elirc.Bot.Command.run(state.sock, state.chan)
        do_listen(state)
      nil ->
        :ok
    end
  end

end