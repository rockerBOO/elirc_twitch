defmodule Elirc.Handler.Names do
  alias Elirc.Channel.Supervisor, as: ChannelSup
  alias Elirc.Channel

  @doc """
  Starts the names handler

  ## Example
  start_link(ExIrc.Client)
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, client)
  end

  def init(client) do
    ExIrc.Client.add_handler client, self

    {:ok, %{client: client}}
  end

  # Handles names lists
  def handle_info({:names, channel, names}, state) do
    # Add each name to the channel
    names |> Enum.each(fn (name) ->
      Channel.add_user_async!(channel, name)
    end)

    {:noreply, state}
  end

  # Handles when a user has joined a channel
  def handle_info({:joined, channel, user}, state) do
    Channel.remove_user(channel, user)

    {:noreply, state}
  end

  # Handles when a user leaves a channel
  def handle_info({:parted, channel, user}, state) do
    Channel.add_user(channel, user)

    {:noreply, state}
  end

  # catch-all
  def handle_info(_, state) do
    {:noreply, state}
  end

  def terminate(reason, state) do
    :ok
  end

  def debug(msg) do
    IO.puts msg
  end
end