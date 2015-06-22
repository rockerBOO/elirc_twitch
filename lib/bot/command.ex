defmodule Elirc.Bot.Command do
  def start_link(client, channel) do
    GenServer.start_link(__MODULE__, [client, channel, noisy?: true])
  end

  def init([client, channel, noisy?: noisy]) do
    state = %{client: client, channel: channel, noisy?: noisy}

    :random.seed(:erlang.now)

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

  # %{command: "!hello"}
  def run(%{command: command}, state) do 
    _run(command, state)
  end

  # !hello
  def run(command, state) do
    _run(command, state)
  end

  defp _run(command, state, options \\ []) do 

    # IO.inspect command
    command = parse_command(command)

    case command do
      {:say, value} -> say(value, state)
      {:sound, value} -> play_sound(value)
      {:cmd, value} -> cmd(value, state)
      # nil -> say_random_emote(state)
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
      "follower" -> {:cmd, "follower"}
      "followed" -> {:cmd, "followed"}
      "elixir" -> {:say, "Elixir is a dynamic, functional language designed for building scalable and maintainable applications. http://elixir-lang.org/"}
      "bot" -> {:say, "https://github.com/rockerBOO/elirc_twitch"}
      "elirc" -> {:say, "https://github.com/rockerBOO/elirc_twitch"}
      "soundlist" -> {:say, "engage, dont, speedlimit, yeahsure"}
      "whatamidoing" -> {:say, "Working on a Twitch Bot in Elixir. Elixir works well with co-currency and messages. This is ideal for IRC chat processing."}
      "itsnotaboutsyntax" -> {:say, "http://devintorr.es/blog/2013/06/11/elixir-its-not-about-syntax/"}
      "excitement" -> {:say, "http://devintorr.es/blog/2013/01/22/the-excitement-of-elixir/"}
      "commands" -> {:say, "!(hello, elixir, resttwitch, bot, soundlist, whatamidoing, itsnotaboutsyntax, excitement)"}
      "twitchapi" -> {:say, "https://github.com/justintv/Twitch-API/blob/master/v3_resources/"}
      "resttwitch" -> {:say, "https://github.com/rockerBOO/rest_twitch"}
      "gravity" -> {:say, "https://github.com/frankyonnetti/gravity-sublime-theme"}
      "flip" -> {:say , "(╯°□°）╯︵┻━┻"}
      _ -> nil
    end
  end

  def say(response, state) do
    debug "Say (#{state.channel}): #{response}"

    if state.noisy? do send_say(response, state) end
    # send_say(response, state)
  end

  def say_random_emote(state) do
    emotes = [
      "Kreygasm", "FrankerZ", "OMGScoots",
      "FailFish", "WutFace"
    ]

    Enum.at(emotes, :random.uniform(length(emotes)) - 1)
      |> send_say(state)
  end

  def send_say(response, state) do
    state.client |> ExIrc.Client.msg(:privmsg, state.channel, response)
  end

  def cmd(value, state) do
    case value do
      "follower" -> say(get_last_follower(), state)
      "followed" -> say(get_last_followed(), state)
      _ -> IO.inspect value
    end
  end

  @doc """
  Gets the last follower to the channel

  ## Examples
      iex> Elirc.Bot.Command.get_last_follower()
  """
  def get_last_follower() do 
    opts = %{"direction" => "desc", "limit" => 1}
    %RestTwitch.Follows.Follow{user: user} = 
      RestTwitch.Channels.followers("rockerboo", opts)
      |> Enum.fetch! 0

    user 
      |> Map.fetch! "display_name"
  end

  def get_last_followed() do
    # /streams/followed
    token = OAuth2.AccessToken.new(%{
      "token_type" => "OAuth ", 
      "access_token" => System.get_env("TWITCH_ACCESS_TOKEN")
    }, OAuth2.Twitch.new())

    %{"display_name" => display_name} = 
      RestTwitch.Users.streams_following(token, %{"limit" => 1})
      |> Map.fetch!("streams")
      |> Enum.fetch!(0)
      |> Map.fetch!("channel")

    display_name 
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end