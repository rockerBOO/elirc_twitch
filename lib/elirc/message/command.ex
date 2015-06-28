defmodule Elirc.Command do
  use GenServer
  alias RestTwitch.Channels
  alias RestTwitch.User
  alias RestTwitch.Follows.Follow
  alias Elirc.Message
  alias Elirc.Command
  alias Elirc.Sound
  alias Elirc.Emoticon

  @doc """

  ## Examples
  start_link(ExIrc.Client, "TWITCH_ACCESS_TOKEN", "#test_channel")
  """
	def start_link(client, token, channel) do
    GenServer.start_link(__MODULE__, [client, token, channel], [])
	end

  def init([client, token, channel]) do
    {:ok, %{client: client, token: token, channel: channel}}
  end

  @doc """
  Runs the command on the CommandPool

  ## Example
  run("follower", "#test_channel")
  """
  def run(cmd, channel) do
    pool_name = Elirc.CommandPool.Supervisor.pool_name()

    :poolboy.transaction(
      pool_name,
      fn(pid) ->
        :gen_server.call(pid, {:run, [cmd: cmd, channel: channel]})
      end
    )
  end

  def route(nil, _, _), do: :ok

  def route({action, {user, value}}, channel, [client, token]) do
    case action do
      :reply -> Message.whisper(user, value)
    end
  end

  def route({action, value}, channel, [client, token]) do
    case action do
      :say -> Message.say(value, channel, [client, token])
      :sound -> Sound.play(value)
      :cmd -> cmd(value, channel, [client, token])
      _ -> :ok
    end
  end

  @doc """
  Process and route command to action

  ## Examples
  cmd("follower", "#test_channel", [ExIrc.Client, "TWITCH_ACCESS_TOKEN"])
  """
  def cmd(cmd, channel, [client, token]) do
    case String.split(cmd) do
      ["follower"] -> Message.say(get_last_follower(), channel, [client, token])
      ["followed"] -> Message.say(get_last_followed(token), channel, [client, token])
      ["song"] -> Message.say(get_last_track(), channel, [client, token])
      ["emote" | emote] -> Message.say(emote(emote), channel, [client, token])
      _ -> IO.inspect cmd
    end
  end

  @doc """
  Process emote details from the emoticon list

  ## Example
  emote("danBad")
  """
  def emote(emote) do
    IO.inspect emote

    Elirc.Emoticon.get_emote(emote)
      |> Elirc.Emoticon.get_emoticon_details()
      |> Poison.encode!()
  end

  @doc """
  Gets the last follower to the channel

  ## Examples
  Elirc.Command.get_last_follower()
  """
  def get_last_follower() do
    opts = [direction: "desc", limit: 1]
  %Follow{user: user} =
      Channels.followers("rockerboo", opts)
      |> Enum.fetch! 0

    user
      |> Map.fetch! "display_name"
  end

  @doc """
  Gets the last followed channel

  ## Example
  get_last_followed("TWITCH_ACCESS_TOKEN")
  """
  def get_last_followed(token) do
    %{"display_name" => display_name} =
      Users.streams_following(token, [limit: 1])
      # |> Map.fetch!("streams")
      |> Enum.fetch!(0)
      |> Map.fetch!(:channel)

    display_name
  end

  @doc """
  Get the last track played on last.fm

  ## Example
  get_last_track()
  """
  def get_last_track() do
    url = "http://ws.audioscrobbler.com/1.0/user/rockerboo/recenttracks.rss"
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Exml.parse(body) |> Exml.get "//item[1]/title"
      {:ok, response} ->
        IO.inspect response
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  @doc """
  Route to alias to true command

  ## Example
      iex> Elirc.Command._alias(["bot"])
      ["elirc"]
  """
  def _alias(cmd_alias) do
    case cmd_alias do
      ["bealight"] -> ["bealright"]
      ["bot"] -> ["elirc"]
      ["glacier"] -> ["theme"]
      ["xfile"] -> ["xfiles"]
      ["h"] -> ["help"]
      ["coming"] -> ["getsmeeverytime"]
      ["wtf"] -> ["talkingabout"]
      ["beatit"] -> ["beat_it"]
      ["waithere"] -> ["waitthere"]
      ["63"] -> ["speedlimit"]
      ["65"] -> ["speedlimit"]
      ["danThink"] -> ["dont"]
      ["cmd"] -> ["commands"]
      ["cmdlist"] -> ["commands"]
      cmd -> cmd
    end
  end

  @doc """
  Parses a command for the command routing

  ## Examples
      iex> Elirc.Command.parse("hello")
      {:say, "Hello"}

      iex> Elirc.Command.parse("engage")
      {:sound, "engage"}

      iex> Elirc.Command.parse("follower")
      {:cmd, "follower"}
  """
  def parse(command) do
    case String.split(command) |> _alias() do
      ["hello"] -> {:say, "Hello"}
      ["help"] -> {:say, "You need help."}
      ["engage"] -> {:sound, "engage"}
      ["dont"] -> {:sound, "dont"}
      ["speedlimit"] -> {:sound, "speedlimit"}
      ["yeahsure"] -> {:sound, "yeahsure"}
      ["xfiles"] -> {:sound, "xfiles"}
      ["wedidit"] -> {:sound, "wedidit"}
      ["toy"] -> {:sound, "toy"}
      ["waitthere"] -> {:sound, "waitthere"}
      ["bealright"] -> {:sound, "bealright"}
      ["injuriesemotional"] -> {:sound, "injuriesemotional"}
      ["getsmeeverytime"] -> {:sound, "getsmeeverytime"}
      ["talkingabout"] -> {:sound, "talkingabout"}
      ["beat_it"] -> {:sound, "beat_it"}
      ["whatsthat"] -> {:sound, "whatsthat"}
      ["stupid"] -> {:sound, "stupid"}
      ["yadda"] -> {:sound, "yadda"}
      ["batman"] -> {:sound, "batman"}
      ["follower"] -> {:cmd, "follower"}
      ["followed"] -> {:cmd, "followed"}
      ["elixir"] -> {:say, "Elixir is a dynamic, functional language designed for building scalable and maintainable applications. http://elixir-lang.org/"}
      ["elirc"] -> {:say, "https://github.com/rockerBOO/elirc_twitch"}
      ["soundlist"] -> {:say, "injuriesemotional, getsmeeverytime, talkingabout, beat_it, stupid, yadda, engage, dont, speedlimit, yeahsure, xfiles, wedidit, toy, waitthere, bealright, whatsthat"}
      ["whatamidoing"] -> {:say, "Working on a Twitch Bot in Elixir. Elixir works well with co-currency and messages. This is ideal for IRC chat processing."}
      ["itsnotaboutsyntax"] -> {:say, "http://devintorr.es/blog/2013/06/11/elixir-its-not-about-syntax/"}
      ["excitement"] -> {:say, "http://devintorr.es/blog/2013/01/22/the-excitement-of-elixir/"}
      ["commands"] -> {:say, "!(hello, elixir, theme, resttwitch, bot, soundlist, whatamidoing, itsnotaboutsyntax, excitement, song, flip)"}
      ["twitchapi"] -> {:say, "https://github.com/justintv/Twitch-API/blob/master/v3_resources/"}
      ["resttwitch"] -> {:say, "https://github.com/rockerBOO/rest_twitch"}
      ["theme"] -> {:say, "http://glaciertheme.com/"}
      ["flip"] -> {:say , "(╯°□°）╯︵┻━┻"}
      ["song"] -> {:cmd, "song"}
      ["emote" | emote] -> {:cmd, Enum.join(["emote" | emote], " ")}
      _ -> nil
    end
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end