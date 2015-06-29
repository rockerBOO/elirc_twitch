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

    sound_list = "data/channels/rockerboo/rockerboo.sounds.json"
      |> File.read!()
      |> Poison.decode!()

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

  def handle_info(info, state) do
    IO.inspect info
    {:noreply, state}
  end

  def terminate(reason, state) do
    IO.inspect reason
    :ok
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end