defmodule Elirc.MessagePool.Worker do
  alias Elirc.Message
  alias Elirc.Command
  alias Elirc.Sound
  alias Elirc.Emoticon
  alias Elirc.Message.Parser, as: MessageParser

  @doc """
  Start the Worker process
  """
  def start_link([client, token]) do
    GenServer.start_link(__MODULE__, [client, token], [])
  end

  def init([client, token]) do
    {:ok, [client, token]}
  end

  @doc """
  Handle incoming messages
  """
  def handle_call({:msg, [channel, user, message]}, _from, state) do
    # IO.inspect "Processing message on:"
    # IO.inspect self
    {:reply, MessageParser.find_data(message, channel, user, state), state}
  end

  def handle_info(reason, state) do
    IO.inspect reason

    {:noreply, state}
  end

  def terminate(reason, state) do
    # IO.inspect reason
    :ok
  end
end