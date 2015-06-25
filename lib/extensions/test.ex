defmodule ConnectionExtension do
  def start_link(ext) do
    GenServer.start_link(__MODULE__, [ext])
  end

  def init([ext]) do
    IO.puts "init add_handler"
    IO.inspect ext
    IO.inspect self
    Elirc.Extension.add_handler ext, self

    {:ok, [ext]}
  end

  def handle_event({:connected, server, port}, state) do
    debug "Connected to #{server}:#{port}"
    {:ok, state}
  end

  # Catch-all
  def handle_info(_, state) do
    {:ok, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
