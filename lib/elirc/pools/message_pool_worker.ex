defmodule Elirc.MessagePool.Worker do
  alias Elirc.Message
  alias Elirc.Command
  alias Elirc.Sound
  alias Elirc.Emoticon

  @doc """
  Start the Worker process
  """
  def start_link([client, token]) do
    GenServer.start_link(__MODULE__, [client, token], [])
  end

  def init([client, token]) do
    {:ok, %{client: client, token: token}}
  end

  @doc """
  Handle incoming messages
  """
  def handle_call([channel, user, message], _from, state) do
    # IO.inspect "Processing message on:"
    # IO.inspect self
    {:reply, process(message, channel, state), state}
  end

  @doc """
  Process message for commands and data points

  ## Examples
  process("!hello", "#test_channel", %{client: ..., token: ...})
  process("danBad danThink", "#test_channel", %{client: ..., token: ...})
  """
  def process(message, channel, state) do
    # IO.puts "Process #{message}"
    case String.lstrip(message) do
      "!" <> command -> command(command, channel, state)
      message -> process_message_for_data(message, state)
    end
  end

  @doc """
  Processes the message for different data points

  ## Example
  Elirc.MessagePool.Worker.process_message_for_data("danBad danBat")
  """
  def process_message_for_data(message, state) do
    emotes = Emoticon.get_all!()
    words = ["danThink", "deIlluminati", "danBat"]

    message
      |> Message.find_emotes(emotes, state)
      |> Message.find_words(words)
      # |> Message.find_users(users)
      |> Message.find_links()
      |> Message.find_spam()
  end


  @doc """
  Process command for the channel

  ## Example
  command("hello", "#test_channel", %{client: ..., token: ...})
  """
  def command(command, channel, state) do
    case Command.parse(command) do
      {:say, message} -> Message.say(message, channel, state.client)
      {:sound, sound} -> play_sound(sound)
      {:cmd, cmd} -> run_command(cmd, channel)
      _ -> :ok
    end
  end

  @doc """
  Plays the sound

  ## Example
  play_sound("xfiles")
  """
  def play_sound(sound) do
    Sound.play(sound)
  end

  @doc """
  Runs a command

  ## Example
  run_command("hello", "#test_channel")
  """
  def run_command(cmd, channel) do
    Command.run(cmd, channel)
  end

  def handle_info(reason, state) do
    IO.inspect reason

    {:noreply, state}
  end

  def terminate(reason, state) do
    IO.inspect reason
    :ok
  end
end