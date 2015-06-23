defmodule Elirc.Bot.Command do
  def start_link(client, token, channel) do
    GenServer.start_link(__MODULE__, [client, token, channel, noisy?: true])
  end

  def init([client, token, channel, noisy?: noisy]) do
    state = %{client: client, token: token, channel: channel, noisy?: noisy}

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
        yeahsure: "/home/rockerboo/Music/movie_clips/yeahsure.mp3",
        xfiles: "/home/rockerboo/Music/movie_clips/xfiles.mp3",
        wedidit: "/home/rockerboo/Music/movie_clips/wedidit.mp3",
        toy: "/home/rockerboo/Music/movie_clips/toy.mp3",
        waitthere: "/home/rockerboo/Music/movie_clips/waithere.mp3",
        bealright: "/home/rockerboo/Music/movie_clips/bealright.mp3",
        whatsthat: "/home/rockerboo/Music/movie_clips/whatsthat.mp3"
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
      "xfiles" -> {:sound, "xfiles"}
      "wedidit" -> {:sound, "wedidit"}
      "toy" -> {:sound, "toy"}
      "waitthere" -> {:sound, "waitthere"}
      "bealright" -> {:sound, "bealright"}
      "whatsthat" -> {:sound, "whatsthat"}
      "follower" -> {:cmd, "follower"}
      "followed" -> {:cmd, "followed"}
      "elixir" -> {:say, "Elixir is a dynamic, functional language designed for building scalable and maintainable applications. http://elixir-lang.org/"}
      "bot" -> {:say, "https://github.com/rockerBOO/elirc_twitch"}
      "elirc" -> {:say, "https://github.com/rockerBOO/elirc_twitch"}
      "soundlist" -> {:say, "engage, dont, speedlimit, yeahsure, xfiles, wedidit, toy, waitthere, bealright, whatsthat"}
      "whatamidoing" -> {:say, "Working on a Twitch Bot in Elixir. Elixir works well with co-currency and messages. This is ideal for IRC chat processing."}
      "itsnotaboutsyntax" -> {:say, "http://devintorr.es/blog/2013/06/11/elixir-its-not-about-syntax/"}
      "excitement" -> {:say, "http://devintorr.es/blog/2013/01/22/the-excitement-of-elixir/"}
      "commands" -> {:say, "!(hello, elixir, resttwitch, bot, soundlist, whatamidoing, itsnotaboutsyntax, excitement)"}
      "twitchapi" -> {:say, "https://github.com/justintv/Twitch-API/blob/master/v3_resources/"}
      "resttwitch" -> {:say, "https://github.com/rockerBOO/rest_twitch"}
      "glacier" -> {:say, "http://glaciertheme.com/"}
      "theme" -> {:say, "http://glaciertheme.com/"}
      "flip" -> {:say , "(╯°□°）╯︵┻━┻"}
      "song" -> {:cmd, "song"}
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
      "followed" -> say(get_last_followed(state.token), state)
      "song" -> say(get_last_track(), state)
      _ -> IO.inspect value
    end
  end

  @doc """
  Gets the last follower to the channel

  ## Examples
      iex> Elirc.Bot.Command.get_last_follower()
  """
  def get_last_follower() do
    opts = [direction: "desc", limit: 1]
    %RestTwitch.Follows.Follow{user: user} =
      RestTwitch.Channels.followers("rockerboo", opts)
      |> Enum.fetch! 0

    user
      |> Map.fetch! "display_name"
  end

  def get_last_followed(token) do
    %{"display_name" => display_name} =
      RestTwitch.Users.streams_following(token, [limit: 1])
      # |> Map.fetch!("streams")
      |> Enum.fetch!(0)
      |> Map.fetch!(:channel)

    display_name
  end

  def get_last_track() do
    url = "http://ws.audioscrobbler.com/1.0/user/rockerboo/recenttracks.rss"
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        last_track  = Exml.parse(body) |> Exml.get "//item[1]/title"
      {:ok, response} ->
        IO.inspect response
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
    last_track
  end

  def terminate(reason, state) do
    IO.inspect reason

    :ok
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end