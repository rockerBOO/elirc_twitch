defmodule BotTest do
  use ExUnit.Case
  alias Elirc.Bot

  @msg ":bentanweihao!~bentanwei@27.96.106.134 PRIVMSG #elixir-lang :makes writing look like a walk in the park"
  test "parsing of PRIVMSG" do
    expected = %{message: "makes writing look like a walk in the park",
             who: "bentanweihao"}
    assert expected == Bot.parse_message(@msg, nil)
  end


end