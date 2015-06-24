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
    # IO.puts "SILENT ----"

    client |> ExIrc.Client.msg(:privmsg, channel, message)
  end

  def find_emotes(message, emotes) do
    emotes
      |> Enum.map fn (emote) -> find_emote(message, emote) end
  end

  def find_emote(message, emote) do
    Regex.compile("\s" <> emote <> "\s")
      |> Regex.run(message)
  end

  def find_spam(message) do
    Elirc.Message.Spam.find(message)
  end

  def find_links(message) do
    Elirc.Message.Link.find(message)
  end

  def find_users(message, channel, users) do
    Elirc.Channel.users(channel)
  end

end