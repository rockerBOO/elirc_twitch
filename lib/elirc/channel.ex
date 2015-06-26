defmodule Elirc.Channel do
  @doc """
  start_link(ExIrc.Client, "#test_channel")
  """
  def start_link(client, channel, opts \\ []) do
    GenServer.start_link(__MODULE__, [client, channel, []], opts)
  end

  def init([client, channel, opts]) do
    users = HashSet.new

    {:ok, %{client: client, channel: channel,
      opts: opts, users: users}}
  end

  @doc """

  ## Examples
      iex> Elirc.Channel.to_atom("test_channel")
  """
  def to_atom(channel) do
    String.to_atom("channel-" <> channel)
  end

  @doc """
  Adds user to channel
  """
	def add_user(user, state) do
    debug "Adding #{user} to users"
    %{state | users: HashSet.put(state.users, user) }
  end

  @doc """
  Removes user from the channel
  """
  def remove_user(user, state) do
    debug "Removing #{user} from users"
    %{state | users: HashSet.delete(state.users, user) }
  end

  @doc """
  Removes user from channel
  """
  def handle_call({:remove, user}, _from, state) do
    {:reply, :ok, remove_user(user, state)}
  end

  @doc """
  Add user to channel
  """
  def handle_call({:add, user}, _from, state) do
    {:reply, :ok, add_user(user, state)}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end

end