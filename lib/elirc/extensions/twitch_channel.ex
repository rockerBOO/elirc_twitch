defmodule TwitchChannel do
  use Elirc.Extension.Command

  def start_link(ext) do
    GenServer.start_link(__MODULE__, [ext],
      [name: __MODULE__])
  end

  def init([ext]) do
    {:ok, [ext]}
  end

  def add_user({user, channel}) do
    IO.inspect user

    {user, channel}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end