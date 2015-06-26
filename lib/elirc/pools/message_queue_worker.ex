defmodule Elirc.MessageQueue.Worker do
  alias Elirc.Message

  @doc """
  Starts the MessageProxy.Worker process

  ## Example
  start_link([ExIrc.Client])
  """
  def start_link([client, token]) do
    GenServer.start_link(__MODULE__, [client, token], [])
  end

  def init([client, token]) do
    {:ok, %{client: client, token: token}}
  end

  def route_message(msg, user, channel, state) do
    :poolboy.transaction(
      Elirc.MessagePool.Supervisor.pool_name(),
      fn (pid) ->
        :gen_server.call(pid, {:msg, [channel, user, msg]}, 15000)
      end
    )
  end

  def receive_msg(msg, user, channel, state) do
    route_message(msg, user, channel, state)
  end

  def handle_call({:msg, [channel, user, msg]}, _from, state) do
    # IO.puts "receive_msg"
    _ = receive_msg(msg, user, channel, state)
    {:reply, :ok, state}
  end

  def handle_info(reason, state) do
    IO.inspect reason

    {:noreply, state}
  end

  def terminate(reason, state) do
    IO.inspect reason
    :ok
  end
end