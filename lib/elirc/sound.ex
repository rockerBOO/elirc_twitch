defmodule Elirc.Sound do
  @doc """
  Sends a request to play the sound in the SoundPool

  ## Examples
  play("xfiles")
  """
  def play(sound) do
     pool_name = Elirc.SoundPool.Supervisor.pool_name()

    :poolboy.transaction(
      pool_name,
      fn(pid) -> :gen_server.call(pid, {:play, sound}, 15000) end
    )
  end

  @doc """
  Play the sound from the sound list

  ## Examples
  play("xfiles", %{xfiles: "/home/rockerboo/Music/movie_clips/xfiles.mp3"}})
  """
  def play(sound, sounds) do
    Map.get(sounds, String.to_atom(sound))
      |> play_file()
  end

  # Handle nil matches with file not found
  def play_file(nil) do
    {:error, "File not found"}
  end

  @doc """
  Plays the sound in the file

  ## Examples
  play_file("/home/rockerboo/Music/movie_clips/xfiles.mp3")
  """
  def play_file(file) do
    case parse_extension(file) do
      "mp3" -> play_mp3(file)
    end
  end

  @doc """
  Plays the file through mpg123

  ## Examples
  play_mp3("../xfiles.mp3")
  """
  def play_mp3(file) do
    debug "Playing " <> file
    Porcelain.exec("mpg123", ["-q", file])
  end

  @doc """
  Parses the extension off the file

  ## Examples
      iex> Elirc.Sound.parse_extension("../xfiles.mp3")
      "mp3"

      iex> Elirc.Sound.parse_extension("../xfiles.ogg")
      "ogg"

      iex> Elirc.Sound.parse_extension("../xfiles.wav")
      "wav"
  """
  def parse_extension(file) do
    String.slice(file, String.length(file)-3, 3)
  end



  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end