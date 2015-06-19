defmodule Elirc.Bot.Command do
  def start_link(client, channel) do
    GenServer.start_link(__MODULE__, [client, channel, noisy?: false])
  end

  def init([client, channel, noisy?: noisy]) do
    state = %{client: client, channel: channel, noisy?: noisy}

    {:ok, state}
  end

  def handle_cast({:process, message}, state) do
    process_command(message, state)
    {:noreply, state}
  end

  def process_command(message, state) do 
    message 
      |> Elirc.Bot.Command.parse_command_from_msg()
      |> Elirc.Bot.Command.run(state)
  end

  # "!hello"
  def parse_command_from_msg("!" <> msg) do
    msg 
      |> String.split()
      |> parse_command_options()
  end

  # Not using the ! prefix, not a command
  def parse_command_from_msg(_) do
    %{command: nil}
  end

  def parse_command_options([head | tail]) do
    %{command: head, options: tail}
  end

  def play_sound(sound) do
    {:ok, sound_client} = Elirc.Sound.start_link(%{
        engage: "/home/rockerboo/Music/movie_clips/engag.mp3",
        dont: "/home/rockerboo/Music/movie_clips/khdont.mp3",
        speedlimit: "/home/rockerboo/Music/movie_clips/speedlimit.mp3",
        yeahsure: "/home/rockerboo/Music/movie_clips/yeahsure.mp3"
      })

    GenServer.cast(sound_client, {:play, sound})
  end  

  def run(%{command: command}, state) do 
    _run(command, state)
  end

  def run(command, state) do
    _run(command, state)
  end

  defp _run(command, state, options \\ []) do 

    # IO.inspect command
    command = parse_command(command)

    case command do
      {:say, value} -> say(value, state)
      {:sound, value} -> play_sound(value)
      nil -> nil
    end
  end

  def parse_command(command) do
    case command do 
      "hello" -> {:say, "Hello"}
      "help" -> {:say, "You need help."}
      "engage" -> {:sound, "engage"}
      "dont" -> {:sound, "dont"}
      "speedlimit" -> {:sound, "speedlimit"}
      "yeahsure" -> {:sound, "yeahsure"}
      "elixir" -> {:say, "Elixir is a dynamic, functional language designed for building scalable and maintainable applications. http://elixir-lang.org/"}
      "github" -> {:say, "https://github.com/rockerBOO/elirc_twitch"}
      "soundlist" -> {:say, "engage, dont, speedlimit, yeahsure"}
      "whatamidoing" -> {:say, "Working on a Twitch Bot in Elixir. Elixir works well with co-currency and messages. This is ideal for IRC chat processing."}
      _ -> nil
    end
  end

  def say(response, state) do
    debug "Say (#{state.channel}): #{response}"
    # Don't talk if silent
    IO.inspect state

    if state.noisy? do send_say(response, state) end
    # send_say(response, state)
  end

  def send_say(response, state) do
    IO.puts "Actually sending the message this time"
    state.client |> ExIrc.Client.msg(:privmsg, state.channel, response)
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end