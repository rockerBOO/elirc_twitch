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
end