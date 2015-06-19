defmodule Elirc.Handler.User do 
  alias Elirc.Users.Supervisor, as: UsersSup
  @moduledoc """
  Handles User joining/parting of the channel
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, client)
  end

  def init(client) do
    state = %{}

    state = Map.put(state, :channel_users, [])
      |> Map.put(:client, client)

    ExIrc.Client.add_handler client, self

    {:ok, state}
  end

  def join_channel(channel, state) do
    channel_users_pid = new_channel(state.client, channel)

    channel_users = state.channel_users 
      |> Enum.into(add_to_channel_users(state.channel_users, 
        channel, channel_users_pid))

    Map.put(state, :channel_users, channel_users)
  end

  def add_users_to_channel(channel, users, state) do
    {:ok, {_, channel_users_pid}} = get_channel_users(state.channel_users, channel)

    IO.puts "add_users_to_channel"
    IO.inspect channel_users_pid

    IO.puts "users"
    IO.inspect users

    :ok = GenServer.call(channel_users_pid, {:add, users})
  end

  def new_channel(client, channel) do
    {:ok, users_pid} = UsersSup.start_child(Elirc.Users.Supervisor, [])
  
    new_state = GenServer.call(users_pid, {:new, channel})

    users_pid
  end

  def add_to_channel_users(channels, channel, users_pid) do
    channels
      |> Enum.into([{channel, users_pid}])
  end

  def get_channel_users(channels, channel) do
    case find_channel(channels, channel) do
      nil -> {:error, "Could not find the channel."}
      pid -> {:ok, pid}
    end
  end

  def find_channel(channels, channel) do
    Enum.find(channels, fn ({chan, _}) -> channel == chan end)
  end

  def remove_channel_from_channel_users(channels, channel) do
    channels 
      |> Enum.reject(fn ({chan, _}) -> channel == chan end)
  end

  def get_users(channels, channel) do
    users = case get_channel_users(channels, channel) do
      {:ok, {_, pid}} -> GenServer.call(pid, {:users, nil})  
      _ -> IO.puts "Could not find the #{channel}"
    end

    users
  end

  def terminate(reason, state) do
    IO.inspect reason
  end

  def handle_info({:names_list, channel, users}, state) do
    add_users_to_channel(channel, users, state)

    {:noreply, state}
  end

  # Bot has joined the channel
  def handle_info({:joined, channel}, state) do    
    debug "Joining #{channel}"

    {:noreply, join_channel(channel, state)}
  end

  # nick has joined the channel
  def handle_info({:joined, channel, user}, state) do
    IO.puts "#{user} has joined #{channel}"

    users = state.channel_users[String.to_atom(channel)] 
      |> GenServer.call({:add, user})

    {:noreply, %{state | users: users}}
  end

  def handle_info({:parted, channel, user}, state) do
    IO.puts "#{user} has left #{channel}"
    IO.puts "Not removing #{user}"
    # Elirc.User.delete(user)
    {:noreply, state}
  end

  # catch-all
  def handle_info(info, state) do
    {:noreply, state}
  end

  def debug(msg) do
    IO.puts msg
  end
end