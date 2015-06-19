defmodule CommandTest do
  use ExUnit.Case
  alias Elirc.Bot.Command

  @message "!hello"
  test "parse hello command" do 
  	expected = %{command: "hello", options: []}

  	assert expected == Command.parse_command_from_msg(@message)
  end

  @message "hello"
  test "parse non-command" do
    expected = %{command: nil}

    assert expected == Command.parse_command_from_msg(@message)
  end

  @command "hello"
  test "parse command for say action" do 
    expected = {:say, "Hello"}

    assert expected == Command.parse_command(@command)
  end

  @command "dont"
  test "parse command for sound action" do 
    expected = {:sound, "dont"}

    assert expected == Command.parse_command(@command)
  end
end