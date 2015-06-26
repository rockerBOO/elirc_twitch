defmodule Elirc.Handler.Message do
  alias Beaker.Counter
  alias Beaker.TimeSeries

  @doc """
  Starts the message handler

  ## Example
  start_link(ExIrc.Client, "ACCESS_TOKEN_HASH")
  """
  def start_link(client, token) do
    GenServer.start_link(__MODULE__, [client, token])
  end

  def init([client, token]) do
    ExIrc.Client.add_handler client, self
    {:ok, %{client: client, token: token}}
  end

  @doc """
  Handles messages sent from IRC
  """
  def handle_info({:received, msg, user, channel}, state) do
    # Add counter increment to channel
    Beaker.Counter.incr(channel)

    spawn_message_queue(msg, user, channel)

    {:noreply, state}
  end

  def spawn_message_queue(msg, user, channel) do
    pool_name = Elirc.MessageQueue.Supervisor.pool_name()

    spawn(fn () ->
      :poolboy.transaction(
        pool_name,
        fn (pid) ->
          :gen_server.call(pid, {:msg, [channel, user, msg]})
        end
      )
    end)
  end

  # Catch all
  def handle_info(info, state) do
    {:noreply, state}
  end

  def terminate(reason, state) do
    IO.inspect reason
    :ok
  end
end