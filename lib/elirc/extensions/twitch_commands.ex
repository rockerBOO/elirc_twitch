defmodule TwitchCommand do
  use Elirc.Extension.Command

  def start_link(ext) do
    GenServer.start_link(__MODULE__, [ext],
      [name: __MODULE__])
  end

  def init([ext]) do
    {:ok, [ext]}
  end

  def command({command, channel, client}) do
    command
  end
end