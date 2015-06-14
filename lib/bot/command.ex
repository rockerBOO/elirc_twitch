defmodule Elirc.Bot.Command do
  def find_command(%{message: message}) do 
    message
      |> parse_command
  end

  def find_command(message) do 
    message 
      |> parse_command
  end

  defp is_command(message) do 
    String.slice(message, 0, 1) == "!"
  end

  defp parse_command(message) do
    # Find ! at the start
    if is_command(message) do
      # Strip off the !
      %{command: String.lstrip(message, ?!)}  
    else
      %{command: nil}
    end
  end 

  def run(%{command: command}, socket, chan) do 
    case command do 
      "hello" -> say(socket, chan, "Hello")
      _ -> "Everything is great!"
    end
  end


  def run(command, socket) do 

  end

  def format_response(chan, response) do
    "PRIVMSG " <> chan <> " :" <> response <> "\r\n"
  end

  defp say(socket, chan, response) do
    response = format_response(chan, response)

    socket |> Socket.Stream.send!(response)
  end

end