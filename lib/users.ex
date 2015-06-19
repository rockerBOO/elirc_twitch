defmodule Elirc.Channel.Users do
  use GenServer
  alias Elirc.BucketList

  def start_link(exirc_client) do
    GenServer.start_link(__MODULE__, [exirc_client])
  end

  def init([client]) do
    {:ok, %{client: client}}
  end

  def new(channel) do
    bucket = BucketList.new(channel)

    %{channel: channel, bucket: bucket}
  end

  def to_bucket(channel) do
    if is_atom(channel) == false do
      channel = String.to_atom channel
    end

    channel
  end

  def get_users(bucket) do
    users = BucketList.get_all(bucket)

    IO.puts "Got these users:"
    IO.inspect users

    users
  end

  def add_users(user, bucket) do
    BucketList.add(user, bucket)
  end

  def add_users([] = users, bucket) do
    Enum.each(users, fn (user) -> add_users(user, bucket) end)
  end

  def handle_call({:users, nil}, _from, state) do
    {:reply, get_users(state.bucket), state}
  end

  def handle_call({:new, channel}, _from, state) do
    {:reply, :ok, Map.merge(state, new(channel))}
  end

  def handle_call({:add, [] = users}, _from, state) do
    IO.puts "Adding a list of users to the channel #{state.bucket}"

    add_users(users, state.bucket)

    {:reply, :ok, state}
  end

  def handle_call({:add, user}, _from, state) do
    IO.puts "Adding #{user} to the channel list  #{state.bucket}"

    add_users(user, state.bucket)

    {:reply, :ok, state}
  end

  def validate_user(user) do
    if is_list(user) do
      IO.puts "user is list"
      false
    end

    if user == nil do
      IO.puts "user is nil"
      false
    end

    if byte_size(user) == 0 do
      IO.puts "user is blank"
      false
    end 

    true
  end

  def handle_call(:logged_on?, {user}, state) do
    logged_on = BucketList.get(user, state.bucket)

    {:reply, logged_on, state}
  end

  def handle_call(:remove, {user}, state) do
    users = BucketList.remove({user})

    {:reply, users, state}
  end

end