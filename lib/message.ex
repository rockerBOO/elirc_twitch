defmodule Elirc.Message do
  defmodule State do
    defstruct channel: "",
              message: "",
              client: nil
  end

  def say(message, channel, client, noisy? \\ true) do
    if noisy? do
      send_say(message, channel, client)
    end
  end

  def send_say(message, channel, client) do
    debug "Say (#{channel}): #{message}"

    client |> ExIrc.Client.msg(:privmsg, channel, message)
  end

  def find_emotes(message, emotes) do
    _ = Elirc.Emoticon.find_emotes!(message, emotes)

    message
  end

  def find_spam(message) do
    Elirc.Message.Spam.find(message)

    message
  end

  def find_links(message) do
    Elirc.Message.Link.find(message)

    message
  end

  def find_words(message, words) do
    words
      |> Enum.map(fn (word) -> find_word(message, word) end)
      |> found_words()

    message
  end

  def find_word(message, word) do
    message
      |> String.split()
      |> Enum.reject(fn (part) -> part != word end)
  end

  def found_words(found) do
    IO.inspect found

    found
      |> Enum.each(fn (word) -> process_word(word) end)
  end

  def process_word(word) do
    case word do
      ["danThink"] -> Elirc.Sound.play("dont")
      ["deIlluminati"] -> Elirc.Sound.play("xfiles")
      _ -> :ok
    end
  end

  def find_users(message, channel, users) do
    Elirc.Channel.users(channel)

    message
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end

end