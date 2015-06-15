defmodule Elirc.Message.Supervisor do
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

end
