defmodule Elirc.Emoticon do

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    _ = start()

    {:ok, []}
  end

  def handle_cast("fetch_and_import", state) do
    fetch_and_import()

    {:noreply, state}
  end

  def start() do
    :ets.new(:emoticons, [
      :ordered_set,
      :named_table,
      :public,
      {:read_concurrency, true}
    ])

    :ets.new(:emote_global, [
      :ordered_set,
      :named_table,
      :public,
      {:read_concurrency, true}
    ])

    :ets.new(:emote_sets, [
      :ordered_set,
      :named_table,
      :public,
      {:read_concurrency, true}
    ])

    :ets.new(:emote_images, [
      :ordered_set,
      :named_table,
      :public,
      {:read_concurrency, true}
    ])

    :ets.new(:emote_subscribers, [
      :ordered_set,
      :named_table,
      :public,
      {:read_concurrency, true}
    ])
  end

  @doc """
  Fetch a list of global emoticons, and parse the json
  """
  def fetch_global_emoticons() do
    "http://twitchemotes.com/api_cache/v2/global.json"
      |> HTTPoison.get!()
      |> Map.fetch!(:body)
      |> Poison.decode!()
      |> Map.fetch!("emotes")
  end


  @doc """
    Fetch a list of subscriber emoticons, and parse the json
  """
  def fetch_subscriber_emoticons() do
    "http://twitchemotes.com/api_cache/v2/subscriber.json"
      |> HTTPoison.get!()
      |> Map.fetch!(:body)
      |> Poison.decode!()
      |> Map.fetch!("channels")
  end

  @doc """
  Fetch a list of images for emoticons, and parse the json
  """
  def fetch_emoticon_images() do
    "http://twitchemotes.com/api_cache/v2/images.json"
      |> HTTPoison.get!()
      |> Map.fetch!(:body)
      |> Poison.decode!()
      |> Map.fetch!("images")
  end

  @doc """
  Fetch a sets list from twitchemotes.com, and parse the json
  """
  def fetch_emoticon_sets() do
    "http://twitchemotes.com/api_cache/v2/sets.json"
      |> HTTPoison.get!()
      |> Map.fetch!(:body)
      |> Poison.decode!()
      |> Map.fetch!("sets")
  end

  @doc """
  Fetch emote lists and import to ETS
  """
  def fetch_and_import() do
    fetch_global_emoticons()
      |> Enum.each fn ({k, v}) -> save(:emote_global, k, v) end

    fetch_subscriber_emoticons()
      |> Enum.each fn ({k, v}) -> save(:emote_subscribers, k, v) end

    fetch_emoticon_images()
      |> Enum.each fn (tup) -> save(:emote_images, tup) end

    fetch_emoticon_sets()
      |> Enum.each fn (tup) -> save(:emote_sets, tup) end
  end


  @doc """
  Save emote to main list of emoticons
  """
  defp save(bucket, key, value) do
    if Map.has_key?(value, "emotes") do
      value
        |> Map.fetch!("emotes")
        |> Enum.each fn (emote) -> save_main_emote(emote) end
    else
      save_main_emote({key, value})
    end
  end

# "4Head": {
#     "description": "This is the face of a popular Twitch streamer. twitch.tv/cadburryftw",
#     "image_id": 354
# },
  defp save_main_emote(emote) do
    case emote do
      %{"code" => code, "image_id" => image_id} ->
        save(:emoticons, {code, %{"image_id" => image_id}})
      emote -> save(:emoticons, emote)
    end
  end

  defp save(bucket, tup) do
    :ets.insert(bucket, tup)
  end

  defp lookup(value, bucket) do
    :ets.lookup(bucket, value)
  end

  @doc """
  Get all the emoticons, global and subscribers
  """
  def get_all!() do
    :ets.match(:emoticons, :"$1")
  end

  @doc """
  Gets the emoticon from the main list

  ## Examples
  get("DansGame")
  get("danBad")
  """
  def get(emoticon) do
    lookup(emoticon, :emoticons)
  end

  @doc """
  Gets the global emoticon result

  ## Example
  get_global_emote("DansGame")
  """
  def get_global_emote(emoticon) do
    lookup(emoticon, :emote_global)
  end

  @doc """
  Gets the set result

  ## Examples
  get_set("203")
  """
  def get_set(set) do
    lookup(set, :emote_sets)
  end

  @doc """
  Gets the subscriber, with emotes and channel info

  ## Example
  get_subscriber("test_channel")
  """
  def get_subscriber(channel) do
    lookup(channel, :emote_subscribers)
  end

  @doc """
  Gets the subscriber emotes

  ## Example
  get_subscriber_emotes("test_channel")
  """
  def get_subscriber_emotes(channel) do
    get_subscriber(channel)
      |> Map.fetch!("emotes")
  end

  @doc """
  Gets the image_id for the emoticon

  ## Example
  get_image_id("DansGame")
  """
  def get_image_id(emoticon) do
    get(emoticon)
      |> Map.fetch!("image_id")
  end

  @doc """

  ## Examples
  has_emote?("danBat danBad", "danBad")
  """
  def has_emote?(message, emote) do
    if find_emote_in_message!(message, get_emote(emote)) == [] do
      false
    else
      IO.puts "Found Emote! #{message} (#{get_emote(emote)})"
      true
    end
  end

  @doc """
  Finds any provided emotes in the message

  ## Examples
  find_emotes!("danBad", [[{"danYay", %{"image_id" => 4604}}], [{"150Cap", %{"image_id" => 32727}}],
      [{"150Cappa", %{"image_id" => 21542}}], [{"danBad", %{"image_id" => 21543}}]])
  """
  def find_emotes!(message, emotes) when is_list(emotes) do
    x = emotes
      |> Enum.map(fn ([{emote, _}]) -> find_emote_in_message!(message, emote) end)
      |> Enum.reject(fn (emotes) -> length(emotes) == 0 end)
      |> Enum.map(fn (emotes) -> Map.put(%{}, hd(emotes), %{"count" => length(emotes)}) end)

    IO.inspect x

    x
  end

  @doc """
  Finds any of the emote in the message

  ## Examples
  find_emote_in_message!("danBat danBad", "danBad")
  """
  def find_emote_in_message!(message, emote) do
    message
      |> String.split()
      |> Enum.reject(fn (part) -> part != emote end)
  end

  @doc """

  ## Examples
  get_emote([{"danBad", %{"image_id" => 32728}}])
  """
  def get_emote([{emote, _}]) do
    emote
  end

  @doc """

  ## Examples
  get_emote({"danBad", %{"image_id" => 32728}})
  """
  def get_emote({emote, _}) do
    emote
  end

  @doc """

  ## Examples
  get_emote("danBad")
  """
  def get_emote(emote) do
    emote
  end
end