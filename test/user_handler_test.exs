defmodule UserHandlerTest do 
  use ExUnit.Case
  alias Elirc.Handler.User, as: UserHandler

	@channels [{"#rockerboo", "pid"}, {"#twitch", "pid2"}]
  @new_channel "#dethridgecraft"
	test "Adding user to channel users" do 
    pid = "pid3"

    expected = [{"#dethridgecraft", pid}, {"#rockerboo", "pid"}, {"#twitch", "pid2"}]

		assert expected == UserHandler.add_to_channel_users(@channels, @new_channel, pid)
	end

  @channel "#rockerboo"
  test "Get list user list process from channel_users" do
    expected = {"#rockerboo", "pid"}

    assert expected == UserHandler.get_channel_users(@channels, @channel)
  end

  @channel "#rockerboo"
  @pid "pid"
  test "Remove user_pid from channel users" do
    expected = [{"#twitch", "pid2"}]

    assert expected == UserHandler.remove_channel_from_channel_users(@channels, @channel)
  end
end