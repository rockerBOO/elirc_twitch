defmodule Elirc.BotController do

  def msg(event, state, data) do

  end


  def echo(msg, state, data) do
    IO.puts "catch_all"
    IO.inspect data
    IO.inspect msg

    {:reply, {:text, ""}, state}
  end

  def echo(message, state) do
    # IO.inspect message

    {:reply, {:text, message}, state}
  end
end