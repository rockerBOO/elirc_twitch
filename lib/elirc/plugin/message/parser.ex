defmodule Elirc.Message.Parser do
  alias Elirc.Message
  alias Elirc.Command
  alias Elirc.Sound
  alias Elirc.Emoticon

  @doc """
  Find emotes in the message

  ## Example
  find_emotes("Hello danLol", [[{"danLol", %{...}], ...], %State{})
  """
  def emotes(message, emotes, channel) do
    Elirc.Emoticon.find_emotes!(message, emotes)
      |> save_emote_metrics()

    message
  end

  @doc """
  Save found emotes to Beaker metrics

  ## Examples
  save_emote_metrics([{"danLove", %{"count" => 3}}])
  """
  def save_emote_metrics(found_emotes) do
    found_emotes
      |> Enum.each(&save_emote_metric(&1))
  end

  @doc """
  Save an emote metric to Beaker

  ## Examples
  save_emote_metric({"danLove", %{"count" => 3}})
  """
  def save_emote_metric(emote_metric) do
    Dict.keys(emote_metric)
      |> Enum.each(fn (emote) ->
        count = Map.fetch!(emote_metric, emote)
          |> Map.fetch!("count")

        Beaker.Counter.incr_by(emote, count)
      end)
  end

  @doc """
  Find spam in the message

  ## Example
  find_spam("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")

  find_spam("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", "#test_channel", "rockerboo")
  """
  def spam(message, channel \\ "", user \\ "") do
    Elirc.Spam.find(message)

    message
  end

  @doc """
  Find links in the message

  ## Example
  find_links("links in the message http://google.com")

  find_links("links in the message http://google.com", "#test_channel", "rockerboo")
  """
  def links(message, channel \\ "", user \\ "") do
    Elirc.Link.find(message)

    message
  end

  @doc """
  Find the words in the message

  ## Examples
      iex> Elirc.Message.find_words("words in danBad message danThink", ["danBad", "danThink"])
      "words in danBad message danThink"
  """
  def words(message, words, channel \\ "", user \\ "") do
    words
      |> Enum.map(fn (word) -> find_word(message, word) end)
      |> process_found_words(channel)

    message
  end

  @doc """
  Find word in message

  ## Examples
      iex> Elirc.Message.find_word("words in danBad message danThink", "danBad")
      ["danBad"]
  """
  def find_word(message, word) do
    message
      |> String.split()
      |> Enum.reject(fn (part) -> part != word end)
  end

  @doc """
  Process found words

  ## Example
  process_found_words(["danBad"], "#test_channel")
  """
  def process_found_words(words, channel) do
    words
      |> Enum.each(fn (word) ->
          process_word_for_commands(word, channel)
        end)
  end

  @doc """
  Processes the word for commands

  ## Example
  process_word_for_commands(["danBat"], "#test_channel"})
  """
  def process_word_for_commands([word|_], channel) do
    case word do
      # ["danThink"] -> Elirc.Sound.play("dont")
      "danBat" -> Elirc.Sound.play("batman")
      # "deIlluminati" -> Elirc.Sound.play("xfiles")
      _ -> :ok
    end
  end

  def process_word_for_commands([], _), do: nil

  @doc """
  Processes the message for different data points

  ## Example
  Elirc.MessagePool.Worker.process_message_for_data("danBad danBat")
  """
  def find_data(message, channel, user, [client, token]) do
    # emotes = Emoticon.get_all!()
    words = ["danThink", "deIlluminati", "danBat"]

    String.lstrip(message)
      |> commands(channel, user)
      # |> emotes(emotes, user, channel)
      |> words(words, channel, user)
      # |> users(channel, user, users)
      |> links(channel, user)
      |> spam(channel, user)
  end

  @doc """
  Process command for the channel

  ## Example
  find_commands("hello")
  """
  def commands(message, channel, user) do
    case is_command?(message) do
      true -> handle_command(message, channel, user)
      false -> message
    end
  end

  def is_command?("!" <> _), do: true
  def is_command?(_), do: false

  def handle_command("!" <> command, channel, user) do
    Command.run(command, channel, user)

    ""
  end

  @doc """
  Find users mentioned in the message

  ## Example
  find_users("words in danBad message danThink", "#test_channel", "rockerboo")
  """
  def users(message, channel, user) do
    Elirc.Channel.users(channel)

    message
  end
end