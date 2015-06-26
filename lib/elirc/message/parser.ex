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
      |> Enum.each(fn (emote_metric) ->
        Dict.keys(emote_metric)
          |> Enum.each(fn (emote) ->
            count = Map.fetch!(emote_metric, emote)
              |> Map.fetch!("count")

            Beaker.Counter.incr_by(emote, count)
        end)
      end)
  end

  @doc """
  Find spam in the message

  ## Example
  find_spam("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
  """
  def spam(message, channel) do
    Elirc.Spam.find(message)

    message
  end

  @doc """
  Find links in the message

  ## Example
  find_links("links in the message http://google.com")
  """
  def links(message, channel) do
    Elirc.Link.find(message)

    message
  end

  @doc """
  Find the words in the message

  ## Examples
      iex> Elirc.Message.find_words("words in danBad message danThink", ["danBad", "danThink"])
      "words in danBad message danThink"
  """
  def words(message, words, channel) do
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
  def find_data(message, channel, [client, token]) do
    emotes = Emoticon.get_all!()
    words = ["danThink", "deIlluminati", "danBat"]

    message
      |> commands(channel)
      |> Command.route(channel, [client, token])

    message
      # |> emotes(emotes, channel)
      |> words(words, channel)
      # |> find_users(channel, users)
      |> links(channel)
      |> spam(channel)
  end

  @doc """
  Process command for the channel

  ## Example
  find_commands("hello")
  """
  def commands(message, channel) do
    case String.lstrip(message) do
      "!" <> command -> Command.parse(command)
      _ -> nil
    end
  end

  @doc """
  Find users mentioned in the message

  ## Example
  find_users("words in danBad message danThink", "#test_channel", ["rockerboo", "dansgaming"])
  """
  def users(message, channel, users) do
    Elirc.Channel.users(channel)

    message
  end
end