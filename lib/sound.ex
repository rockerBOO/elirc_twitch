defmodule Elirc.Sound do
  def start_link(file) do
    GenServer.start_link(__MODULE__, [file])
  end

  def init([sounds]) do
    {:ok, %{sounds: sounds}}
  end

  def handle_cast({:play, sound}, state) do
    play(sound, state)

    {:noreply, state}
  end

  def play(sound, state) do 
    file = Map.get(state.sounds, String.to_atom(sound))
      |> play_file(state)
  end

  def play_file(nil, state) do
    IO.puts "No file found"
  end

  def play_file(file, state) do
    case parse_sound_type(file) do 
      "mp3" -> play_mp3(file, state)
    end  
  end

  def parse_sound_type(file) do
    debug file
    String.slice(file, String.length(file)-3, 3)
  end

  def play_mp3(file, state) do
    debug "Playing " <> file
    System.cmd "mpg123", ["-q", file]
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end