defmodule Elirc.Message do
  defmodule State do
    defstruct channel: "",
              message: "",
              client: nil
  end

  @doc """
  Say message to channel

  ## Example
  say("Hello", "#test_channel", ExIrc.Client, true)
  """
  def say(message, channel, client, noisy? \\ true) do
    if noisy? do
      send_say(message, channel, client)
    end
  end

  @doc """
  Sends the message to the IRC server

  ## Example
  send_say("Hello", "#test_channel", ExIrc.Client)
  """
  def send_say(message, channel, client) do
    debug "Say (#{channel}): #{message}"

    client |> ExIrc.Client.msg(:privmsg, channel, message)
  end

  @doc """
  Find emotes in the message

  ## Example
  find_emotes("Hello danLol", [[{"danLol", %{...}], ...], %State{})
  """
  def find_emotes(message, emotes, state) do
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
  def find_spam(message) do
    Elirc.Spam.find(message)

    message
  end

  @doc """
  Find links in the message

  ## Example
  find_links("links in the message http://google.com")
  """
  def find_links(message) do
    Elirc.Link.find(message)

    message
  end

  @doc """
  Find the words in the message

  ## Examples
      iex> Elirc.Message.find_words("words in danBad message danThink", ["danBad", "danThink"])
      "words in danBad message danThink"
  """
  def find_words(message, words) do
    words
      |> Enum.map(fn (word) -> find_word(message, word) end)
      |> process_found_words()

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
  process_found_words(["danBad"])
  """
  def process_found_words(words) do
    words
      |> Enum.each(fn (word) ->
          process_word_for_commands(word)
        end)
  end

  @doc """
  Processes the word for commands

  ## Example
  process_word_for_commands(["danBat"])
  """
  def process_word_for_commands([word]) do
    case word do
      # ["danThink"] -> Elirc.Sound.play("dont")
      "danBat" -> Elirc.Sound.play("batman")
      "deIlluminati" -> Elirc.Sound.play("xfiles")
      _ -> :ok
    end
  end

  def process_word_for_commands([]), do: nil

  @doc """
  Find users mentioned in the message

  ## Example
  find_users("words in danBad message danThink", "#test_channel", ["rockerboo", "dansgaming"])
  """
  def find_users(message, channel, users) do
    Elirc.Channel.users(channel)

    message
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end