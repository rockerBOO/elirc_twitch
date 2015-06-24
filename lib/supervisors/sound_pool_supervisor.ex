defmodule Elirc.SoundPool.Supervisor do
  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
	    poolboy_config = [
	      {:name, {:local, pool_name()}},
	      {:worker_module, Elirc.SoundPool.Worker},
	      {:size, 2},
	      {:max_overflow, 0}
	    ]

      sound_list = %{
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
      }

	    children = [
	      :poolboy.child_spec(pool_name(), poolboy_config, sound_list)
	    ]

	    options = [
	      strategy: :one_for_one,
	      name: Elirc.SoundPool.Supervisor
	    ]

	    Supervisor.start_link(children, options)
 	end

  def pool_name() do
    :sound_pool
  end

  def terminate(reason, state) do
    IO.inspect reason
    :ok
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end