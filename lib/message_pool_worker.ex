defmodule Elirc.MessagePool.Worker do
  alias Elirc.Message

  def start_link([client, token]) do
    GenServer.start_link(__MODULE__, [client, token], [])
  end

  def init([client, token]) do
    {:ok, %{client: client, token: token}}
  end

  def handle_cast([channel, user, message], state) do
    process(message, channel, state)

    {:noreply, state}
  end

  def process(message, channel, state) do
    case String.lstrip(message) do
      "!" <> command -> command(command, channel, state)
      message -> process_message_for_data(message)
    end
  end

  @doc """

  ## Example
  Elirc.MessagePool.Worker.process_message_for_data("danBad danBat")
  """
  def process_message_for_data(message) do
    emotes = Elirc.Emoticon.get_all!()

    message
      |> Message.find_emotes(emotes)
      # |> Message.find_users(users)
      |> Message.find_links()
      |> Message.find_spam()
  end

  def command(command, channel, state) do
    case parse_command(command) do
      {:say, message} -> Message.say(message, channel, state.client)
      {:sound, sound} -> play_sound(sound, channel, state)
      {:cmd, cmd} -> run_command(cmd, channel, state)
      _ -> :ok
    end
  end

  def play_sound(sound, channel, state) do
   pool_name = Elirc.SoundPool.Supervisor.pool_name()

    :poolboy.transaction(
      pool_name,
      fn(pid) -> :gen_server.call(pid, {:play, sound}, 5000) end
    )
  end

  def run_command(cmd, channel, state) do
    pool_name = Elirc.CommandPool.Supervisor.pool_name()

    :poolboy.transaction(
      pool_name,
      fn(pid) ->
        :gen_server.call(pid, {:run, [cmd: cmd, channel: channel]})
      end
    )
  end

  def parse_command(command) do
    case command do
      "hello" -> {:say, "Hello"}
      "help" -> {:say, "You need help."}
      "engage" -> {:sound, "engage"}
      "dont" -> {:sound, "dont"}
      "speedlimit" -> {:sound, "speedlimit"}
      "yeahsure" -> {:sound, "yeahsure"}
      "xfiles" -> {:sound, "xfiles"}
      "wedidit" -> {:sound, "wedidit"}
      "toy" -> {:sound, "toy"}
      "waitthere" -> {:sound, "waitthere"}
      "bealright" -> {:sound, "bealright"}
      "injuriesemotional" -> {:sound, "injuriesemotional"}
      "getsmeeverytime" -> {:sound, "getsmeeverytime"}
      "talkingabout" -> {:sound, "talkingabout"}
      "beat_it" -> {:sound, "beat_it"}
      "whatsthat" -> {:sound, "whatsthat"}
      "stupid" -> {:sound, "stupid"}
      "yadda" -> {:sound, "yadda"}
      "follower" -> {:cmd, "follower"}
      "followed" -> {:cmd, "followed"}
      "elixir" -> {:say, "Elixir is a dynamic, functional language designed for building scalable and maintainable applications. http://elixir-lang.org/"}
      "bot" -> {:say, "https://github.com/rockerBOO/elirc_twitch"}
      "elirc" -> {:say, "https://github.com/rockerBOO/elirc_twitch"}
      "soundlist" -> {:say, "injuriesemotional, getsmeeverytime, talkingabout, beat_it, stupid, yadda, engage, dont, speedlimit, yeahsure, xfiles, wedidit, toy, waitthere, bealright, whatsthat"}
      "whatamidoing" -> {:say, "Working on a Twitch Bot in Elixir. Elixir works well with co-currency and messages. This is ideal for IRC chat processing."}
      "itsnotaboutsyntax" -> {:say, "http://devintorr.es/blog/2013/06/11/elixir-its-not-about-syntax/"}
      "excitement" -> {:say, "http://devintorr.es/blog/2013/01/22/the-excitement-of-elixir/"}
      "commands" -> {:say, "!(hello, elixir, theme, resttwitch, bot, soundlist, whatamidoing, itsnotaboutsyntax, excitement, song, flip)"}
      "twitchapi" -> {:say, "https://github.com/justintv/Twitch-API/blob/master/v3_resources/"}
      "resttwitch" -> {:say, "https://github.com/rockerBOO/rest_twitch"}
      "glacier" -> {:say, "http://glaciertheme.com/"}
      "theme" -> {:say, "http://glaciertheme.com/"}
      "flip" -> {:say , "(╯°□°）╯︵┻━┻"}
      "song" -> {:cmd, "song"}
      _ -> nil
    end
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