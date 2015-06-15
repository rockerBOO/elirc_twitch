defmodule Elirc.Sound do
  def start_link(file) do
    GenServer.start_link(__MODULE__, [file])
  end

  def init([file]) do
    

    {:ok, %{file: file}}
  end

  def handle_cast({:play, play}, state) do
    play_mp3(state.file)

    {:noreply, state}
  end

  def play_mp3(file) do
    debug "Playing " <> file
    System.cmd "mpg123", ["-q", file]
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end