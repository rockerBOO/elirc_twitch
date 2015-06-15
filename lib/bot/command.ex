defmodule Elirc.Bot.Command do
  # %{message: "Hello"}
  def find_command(%{message: message}) do 
    message
      |> parse_command
  end

  # "Hello"
  def find_command(message) do 
    message 
      |> parse_command
  end

  defp is_command(message) do 
    String.slice(message, 0, 1) == "!"
  end

  # defp parse_command(<<! :: command>>) do
  #   %{command: command}
  # end

  defp parse_command(message) do
    # Find ! at the start
    if is_command(message) do
      # Strip off the !
      %{command: String.lstrip(message, ?!)}  
    else
      %{command: nil}
    end
  end 

  def run(%{command: command}, client, chan) do 
    _run(command, client, chan)
  end

  def run(command, client, chan) do
    _run(command, client, chan)
  end

  def play_sound(sound) do
    case sound do 
      "engage" -> play_mp3 "/home/rockerboo/Music/movie_clips/engag.mp3"
      "dont" -> play_mp3 "/home/rockerboo/Music/movie_clips/khdont.mp3"
      "speedlimit" -> play_mp3 "/home/rockerboo/Music/movie_clips/speedlimit.mp3"
      "yeahsure" -> play_mp3 "/home/rockerboo/Music/movie_clips/yeahsure.mp3"
    end
  end

  def play_mp3(file) do 
    debug "Playing " <> file

    System.cmd "mpg123", [file]
  end

  defp _run(command, client, chan, options \\ []) do 
    IO.inspect command
    case command do 
      "hello" -> say(client, chan, "Hello")
      "help" -> say(client, chan, "You need help.")
      "engage" -> play_sound "engage"
      "dont" -> play_sound "dont"
      "speedlimit" -> play_sound "speedlimit"
      "yeahsure" -> play_sound "yeahsure"
      _ -> "Everything is great!"
    end
  end

  def say(client, chan, response) do
    debug response <> " to " <> chan
    client |> ExIrc.Client.msg(:privmsg, chan, response)
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end