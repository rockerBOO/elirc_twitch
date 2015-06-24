defmodule Elirc.CommandPool.Worker do
  alias Elirc.Message

  def start_link([client, token]) do
    GenServer.start_link(__MODULE__, [client, token], [])
  end

  def init([client, token]) do
    {:ok, %{client: client, token: token}}
  end

  def handle_call({:run, [cmd: cmd, channel: channel]}, _from, state) do

    Elirc.Command.cmd(cmd, channel, state.token, state.client)

    {:reply, :ok, state}
  end
end