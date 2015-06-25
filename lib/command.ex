defmodule Elirc.Command do
  use GenServer
  alias RestTwitch.Channels
  alias RestTwitch.User
  alias RestTwitch.Follows.Follow
  alias Elirc.Message

	def start_link(client, token, channel) do
    GenServer.start_link(__MODULE__, [client, token, channel], [])
	end

  def init([client, token, channel]) do
    {:ok, %{client: client, token: token, channel: channel}}
  end

  def cmd(cmd, channel, token, client) do
    case String.split(cmd) do
      ["follower"] -> Message.say(get_last_follower(), channel, client)
      ["followed"] -> Message.say(get_last_followed(token), channel, client)
      ["song"] -> Message.say(get_last_track(), channel, client)
      ["emote" | emote] -> Message.say(emote(emote), channel, client)
      _ -> IO.inspect cmd
    end
  end

  def emote(emote) do
    IO.inspect emote

    Elirc.Emoticon.get_emote(emote)
      |> Elirc.Emoticon.get_emoticon_details()
      |> Poison.encode!()
  end

  @doc """
  Gets the last follower to the channel

  ## Examples
      iex> Elirc.Bot.Command.get_last_follower()
  """
  def get_last_follower() do
    opts = [direction: "desc", limit: 1]
    %Follow{user: user} =
      Channels.followers("rockerboo", opts)
      |> Enum.fetch! 0

    user
      |> Map.fetch! "display_name"
  end

  def get_last_followed(token) do
    %{"display_name" => display_name} =
      Users.streams_following(token, [limit: 1])
      # |> Map.fetch!("streams")
      |> Enum.fetch!(0)
      |> Map.fetch!(:channel)

    display_name
  end

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

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end