defmodule Elirc.Handler.User do 
  @moduledoc """
  Handles User joining/parting of the channel
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, client)
  end

  def init(client) do
    {:ok, client}
  end

  # Bot has joined the channel
  def handle_info({:joined, channel}, state) do    
    users = Elirc.Users.start_link(channel)

    {:noreply, %{state | users: users}}
  end

  # nick has joined the channel
  def handle_info({:joined, channel, user}, state) do
    users = GenServer.call(state.users, {:add, user})

    {:noreply, %{state | users: users}}
  end

  #
  def handle_info({:parted, user}, state) do
    Elric.User.delete(user)
    {:noreply, state}
  end

  # catch-all
  def handle_info(info, state) do
    {:noreply, state}
  end
end