defmodule Elirc.Channel do
  @doc """
  start_link(ExIrc.Client, "#test_channel")
  """
  def start_link(client, channel, opts, process_opts \\ []) do
    # IO.puts "Starting the #{channel} process"
    GenServer.start_link(__MODULE__, [client, channel, opts], process_opts)
  end

  def init([client, channel, opts]) do
    users = HashSet.new

    {:ok, %{client: client, channel: channel,
      opts: opts, users: users}}
  end

  def pid(channel) do
    to_atom(channel)
  end

  def state(pid) do
    state = :gen_server.call(pid, :state)
    %{client:  state.client,
     channel: state.channel,
     opts:    state.opts,
     users:   state.users}
  end

  def handle_call(:state, _from, state), do: {:reply, state, state}

  @doc """

  ## Examples
      iex> Elirc.Channel.to_atom("#test_channel")
      :"channel-#test_channel"
  """
  def to_atom(channel) do
    String.to_atom("channel-" <> channel)
  end

  def add_user_async!(channel, user) do
    GenServer.cast(pid(channel), {:add, user})
  end

  @doc """
  Adds user to channel
  """
	def add_user(channel, user) do
    GenServer.call(pid(channel), {:add, user})
  end

  @doc """
  Removes user from the channel
  """
  def remove_user(channel, user) do
    GenServer.call(pid(channel), {:remove, user})
  end

  @doc """
  Removes user from channel
  """
  def handle_call({:remove, user}, _from, state) do
    debug "Removing #{user} from #{state.channel}"
    {:reply, :ok, remove_user_from_state(user, state)}
  end

  @doc """
  Removes user from channel, asyncly
  """
  def handle_cast({:remove, user}, state) do
    debug "Removing #{user} from #{state.channel}"
    {:reply, :ok, remove_user_from_state(user, state)}
  end

  @doc """
  Add user to channel
  """
  def handle_call({:add, user}, _from, state) do
    debug "Adding #{user} to #{state.channel}"
    {:reply, :ok, add_user_to_state(user, state)}
  end

  @doc """
  Add user to channel, asyncly
  """
  def handle_cast({:add, user}, state) do
    debug "Adding #{user} to #{state.channel}"
    {:reply, :ok, add_user_to_state(user, state)}
  end

  @doc """
  Adds user to HashSet in state

  ## Examples
      Elirc.Channel.add_user_to_state("rockerboo", %{users: HashSet.new})
      %{users: #HashSet<["rockerboo"]>}
  """
  def add_user_to_state(user, state) do
    %{state | users: HashSet.put(state.users, user) }
  end

  @doc """
  Remove user to HashSet in state

  ## Examples
      users = HashSet.new
      Elirc.Channel.remove_user_from_state("rockerboo", %{users: HashSet.put(users, "rockerboo")})
      %{users: #HashSet<[]>}
  """
  def remove_user_from_state(user, state) do
    %{state | users: HashSet.delete(state.users, user) }
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end

end