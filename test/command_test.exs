defmodule CommandTest do
  use ExUnit.Case

  alias Elirc.Bot.Command

  @message %{message: "!hello"}
  test "parse hello command" do 
  	expected = %{command: "hello"}

  	assert expected == Command.find_command(@message)
  	assert expected == Command.find_command(@message[:message])
  end

  @response "Hello"
  test "formatting response for commands" do
  	expected = "PRIVMSG #rockerboo :Hello\r\n"

  	assert expected == Command.format_response("#rockerboo", @response)
  end

end