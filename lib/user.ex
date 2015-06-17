defmodule Elirc.User do
  def start_link(channel, client) do
    GenServer.start_link(__MODULE__, %{channel: channel, client: client})
  end

  def init(%{channel: channel, client: client}) do
    users = GenServer.call(client, {:channel_users, channel})

    bucket = Elirc.BucketList.start_link(channel, users)

    {:ok, %{channel | bucket: bucket}}
  end

  def handle_call(:add, {user}, state) do
    GenServer.call(state.bucket, :add, {user})

    {:reply, :ok, state}
  end

  def handle_call(:logged_on?, {user}, state) do
    logged_on = GenServer.call(state.bucket, user)

    {:reply, logged_on, state}
  end

  def handle_call(:remove, {user}, state) do
    users = GenServer.call(state.bucket, :remove, {user})

    {:reply, users, state}
  end
end