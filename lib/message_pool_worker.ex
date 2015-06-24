defmodule Elirc.MessagePool.Worker do
  alias Elirc.Message

  def start_link([client, token]) do
    GenServer.start_link(__MODULE__, [client, token], [])
  end

  def init([client, token]) do
    {:ok, %{client: client, token: token}}
  end

  def handle_call([channel, user, message], _from, state) do
    {:reply, process(message, channel, state), state}
  end

  def process(message, channel, state) do
    case String.lstrip(message) do
      "!" <> command -> command(command, channel, state)
      message -> process_message_for_data(message)
    end
  end

  def process_message_for_data(message) do
    # emotes = Elirc.Emoticon.get_all!()
    emotes = []

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
    {:ok, sound_client} = Elirc.Sound.start_link(%{
        engage: "/home/rockerboo/Music/movie_clips/engag.mp3",
        dont: "/home/rockerboo/Music/movie_clips/khdont.mp3",
        speedlimit: "/home/rockerboo/Music/movie_clips/speedlimit.mp3",
        yeahsure: "/home/rockerboo/Music/movie_clips/yeahsure.mp3",
        xfiles: "/home/rockerboo/Music/movie_clips/xfiles.mp3",
        wedidit: "/home/rockerboo/Music/movie_clips/wedidit.mp3",
        toy: "/home/rockerboo/Music/movie_clips/toy.mp3",
        waitthere: "/home/rockerboo/Music/movie_clips/waithere.mp3",
        bealright: "/home/rockerboo/Music/movie_clips/bealright.mp3",
        whatsthat: "/home/rockerboo/Music/movie_clips/whatsthat.mp3",
        injuriesemotional: "/home/rockerboo/Music/movie_clips/injuriesemotional.mp3",
        getsmeeverytime: "/home/rockerboo/Music/movie_clips/getsmeeverytime.mp3",
        talkingabout: "/home/rockerboo/Music/movie_clips/talkingabout.mp3",
        awkward: "/home/rockerboo/Music/movie_clips/awkward.mp3",
        beat_it: "/home/rockerboo/Music/movie_clips/beat_it.mp3",
        stupid: "/home/rockerboo/Music/movie_clips/stupid.mp3",
        yadda: "/home/rockerboo/Music/movie_clips/yadda.mp3",
      })

    GenServer.cast(sound_client, {:play, sound})
  end

  def run_command(cmd, channel, state) do
    {:ok, command_pid} = Elirc.Command.start_link(state.client, state.token, channel)

    GenServer.cast(command_pid, {:cmd, cmd})
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
end