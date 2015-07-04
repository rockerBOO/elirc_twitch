defmodule TwitchExtension do
  use Elirc.Extension.Message

  def start_link(ext) do
    GenServer.start_link(__MODULE__, [ext], [name: __MODULE__])
  end

  def init([ext]) do
    {:ok, [ext]}
  end

  def message({msg, user, channel}) do
    # IO.inspect msg

    msg
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end