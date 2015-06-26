defmodule Elirc.MessageProxy.Worker do
  alias Elirc.Message

  def start_link([client]) do
    GenServer.start_link(__MODULE__, [client], [])
  end

  def init([client]) do
    {:ok, %{client: client}}
  end

  def spawnie(msg, user, channel, state) do
    :poolboy.transaction(
      Elirc.MessagePool.Supervisor.pool_name(),
      fn (pid) ->
        spawn(fn () -> # IO.inspect "New Worker:"; IO.inspect self;
          Elirc.MessagePool.Worker.process(msg, channel, state)
        end)
      end
    )

  end

  def receive_msg(msg, user, channel, state) do
    pool_name = Elirc.MessagePool.Supervisor.pool_name()

    # IO.puts "Calling MessagePool.Worker for #{msg}"

    spawnie(msg, user, channel, state)
  end

  def handle_call({:receive_msg, [msg, user, channel]}, _from, state) do
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