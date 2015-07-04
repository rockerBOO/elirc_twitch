defmodule TwitchCommand do
  use Elirc.Extension.Command
  alias RestTwitch.Channels
  alias RestTwitch.Users
  alias RestTwitch.Follows.Follow
  alias Elirc.Message
  alias Elirc.Command
  alias Elirc.Sound
  alias Elirc.Emoticon

  def start_link(ext) do
    GenServer.start_link(__MODULE__, [ext],
      [name: __MODULE__])
  end

  def init([ext]) do
    {:ok, [ext]}
  end

  def command({command, channel, user, config}) do
    case String.split(command) do
      ["follower"] -> Message.say(get_last_follower(), channel, config)
      ["followed"] -> Message.say(get_last_followed(config.token), channel, config)
      ["song"] -> Message.say(get_last_track(), channel, config)
      _ -> IO.inspect command
    end

    command
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
      Users.streams_following(token, %{limit: 1})
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
end