defmodule Elirc.Bot.Command do
  def start_link(client, channel) do
    GenServer.start_link(__MODULE__, [client, channel])
  end

  def init([client, channel]) do
    state = %{client: client, channel: channel}

    {:ok, state}
  end

  def handle_cast({:process, message}, state) do
    command = message 
      |> Elirc.Bot.Command.parse_command()
      |> Elirc.Bot.Command.run(state)

    {:noreply, state}
  end

  # "!hello"
  def parse_command("!" <> command) do
    command 
      |> String.split()
      |> parse_command_options()
  end

  # Not using the ! prefix, not a command
  def parse_command(command) do
    %{command: nil}
  end

  def parse_command_options([head | tail]) do
    %{command: head, options: tail}
  end

  def play_sound(sound) do
    case sound do 
      "engage" -> play_mp3 "/home/rockerboo/Music/movie_clips/engag.mp3"
      "dont" -> play_mp3 "/home/rockerboo/Music/movie_clips/khdont.mp3"
      "speedlimit" -> play_mp3 "/home/rockerboo/Music/movie_clips/speedlimit.mp3"
      "yeahsure" -> play_mp3 "/home/rockerboo/Music/movie_clips/yeahsure.mp3"
    end
  end

  def play_mp3(file) do
    {:ok, sound} = Elirc.Sound.start_link(file)

    GenServer.cast(sound, {:play, true})
  end  

  def run(%{command: command}, state) do 
    _run(command, state)
  end

  def run(command, state) do
    _run(command, state)
  end

  defp _run(command, state, options \\ []) do 
    # IO.inspect command
    case command do 
      "hello" -> say("Hello", state)
      "help" -> say("You need help.", state)
      "engage" -> play_sound("engage")
      "dont" -> play_sound("dont")
      "speedlimit" -> play_sound("speedlimit")
      "yeahsure" -> play_sound("yeahsure")
      "elixir" -> say("Elixir is a dynamic, functional language designed for building scalable and maintainable applications.", state)
      "github" -> say("https://github.com/rockerBOO/elirc_twitch", state)
      "soundlist" -> say("engage, dont, speedlimit, yeahsure", state)
      "whatamidoing" -> say("Working on a Twitch Bot in Elixir. Elixir works well with co-currency and messages. This is ideal for IRC chat processing.", state)
      _ -> "Everything is great!"
    end
  end

  def say(response, state) do
    debug "Say (#{state.channel}): #{response}"
    # Don't talk if silent
    # if state.noisy? do send_say(state, chan, response) end
    send_say(response, state)
  end

  def send_say(response, state) do
    state.client |> ExIrc.Client.msg(:privmsg, state.channel, response)
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end