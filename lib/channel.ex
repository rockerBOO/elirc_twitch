defmodule Elirc.Channel do
  @doc """
  client = ExIrc.Client
  channel = "#channel"
  """
  def start_link(client, channel, opts \\ []) do
    GenServer.start_link(__MODULE__, [client, channel], opts)
  end

  def init([client, channel]) do
    IO.inspect channel
    users = HashSet.new

    {:ok, [client, channel, users]}
  end

  @doc """
  Adds user to channel
  """
	def add_user(user, [client, channel, users]) do
    IO.puts "Adding #{user} to users"
    users = HashSet.put(users, user)

    [client, channel, users]
  end

  @doc """
  Removes user from the channel
  """
  def remove_user(user, [client, channel, users]) do
    IO.puts "Removing #{user} from users"
    users = HashSet.delete(users, user)

    [client, channel, users]
  end

  def users(channel) do

  end

  def get_users(state) do

  end

  def handle_call({:remove, user}, _from, state) do
    {:reply, :ok, remove_user(user, state)}
  end

  def handle_call({:add, user}, _from, state) do
    {:reply, :ok, add_user(user, state)}
  end

  def handle_info(info, state) do
    IO.inspect info
  end
end