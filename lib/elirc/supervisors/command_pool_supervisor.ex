defmodule Elirc.CommandPool.Supervisor do
  def start_link(client, token) do
    GenServer.start_link(__MODULE__, [client, token])
  end

  def get_commands_from_sounds(sounds) do
    Map.keys(sounds)
      |> Enum.map(fn (sound) ->
          {sound, ["sound", sound]}
        end)
      |> Enum.into(%{})
  end

  def init([client, token]) do
	    poolboy_config = [
	      {:name, {:local, pool_name()}},
	      {:worker_module, Elirc.CommandPool.Worker},
	      {:size, 2},
	      {:max_overflow, 0}
	    ]

      sounds = "data/channels/rockerboo/rockerboo.sounds.json"
        |> File.read!()
        |> Poison.decode!()

      commands = "data/channels/rockerboo/rockerboo.commands.json"
        |> File.read!()
        |> Poison.decode!()
        |> Map.merge(get_commands_from_sounds(sounds))



      aliases = "data/channels/rockerboo/rockerboo.alias.json"
        |> File.read!()
        |> Poison.decode!()

	    children = [
	      :poolboy.child_spec(pool_name(), poolboy_config, [client, token, commands, aliases])
	    ]

	    options = [
	      strategy: :one_for_one,
	      name: Elirc.CommandPool.Supervisor
	    ]

	    Supervisor.start_link(children, options)
 	end

  def pool_name() do
    :command_pool
  end

  def terminate(reason, state) do
    IO.inspect reason
    :ok
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end