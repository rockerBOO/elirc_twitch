defmodule Elirc.Extension.Whisper do
  use Elirc.Extension.Message

  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    {:ok, []}
  end


end