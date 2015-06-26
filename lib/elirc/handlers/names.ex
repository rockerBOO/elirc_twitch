defmodule Elirc.Handler.Names do
  alias Elirc.Channel.Supervisor, as: ChannelSup
  @moduledoc """
  Handles Users joining/parting of the channel
  """

  @doc """
  Starts the names handler

  ## Example
  start_link(ExIrc.Client)
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, client)
  end

  def init(client) do
    state = %{}

    state
      |> Map.put(:client, client)

    ExIrc.Client.add_handler client, self

    {:ok, state}
  end

  def terminate(reason, state) do
    :ok
  end

  # Handles names lists
  def handle_info({:names, channel, names}, state) do
    {:noreply, state}
  end

  # Handles when a user has joined a channel
  def handle_info({:joined, channel, user}, state) do
    # IO.puts "#{user} has joined #{channel}"

    Elirc.Channel.to_atom(channel)
      |> GenServer.call({:add, user})

    {:noreply, state}
  end

  # Handles when a user leaves a channel
  def handle_info({:parted, channel, user}, state) do
    # IO.puts "#{user} has left #{channel}"

    Elirc.Channel.to_atom(channel)
      |> GenServer.call({:remove, user})

    {:noreply, state}
  end

  # catch-all
  def handle_info(_, state) do
    {:noreply, state}
  end

  def debug(msg) do
    IO.puts msg
  end
end