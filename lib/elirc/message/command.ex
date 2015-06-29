defmodule Elirc.Command do
  use GenServer
  alias RestTwitch.Channels
  alias RestTwitch.User
  alias RestTwitch.Follows.Follow
  alias Elirc.Message
  alias Elirc.Command
  alias Elirc.Sound
  alias Elirc.Emoticon

  @doc """
  Runs the command on the CommandPool

  ## Example
  run("follower", "#test_channel")
  """
  def run(cmd, channel, user) do
    pool_name = Elirc.CommandPool.Supervisor.pool_name()

    # debug "Running #{cmd} on #{channel}"

    :poolboy.transaction(
      pool_name,
      fn(pid) ->
        try do
          :gen_server.call(pid, {:run, {cmd, channel, user}})
        catch
          :exit, {:timeout, _} -> {:error, :timeout}
        end
      end
    )
  end

  def split_response([action | value]), do: {action, hd(value)}
  def split_response(_), do: {"", nil}

  def route(nil, _, _, _), do: :ok

  def route(cmd, channel, user, config) do
    # debug "Routing for #{cmd} in #{channel}"

    {action, value} = process(cmd, channel, user, config)
      |> split_response()

    case action do
      "reply" -> Message.whisper(value, user, config)
      "say" -> Message.say(value, channel, config)
      "sound" -> Sound.play(value)
      "cmd" -> exec(value, channel, user, config)
      _ -> :ok
    end
  end

  def exec(command, channel, user, config) do
    Elirc.Extension.command(command, channel, user, config)
  end

  def process(command, channel, user, config) do
    parse(command, config.commands, config.aliases)
  end

  @doc """
  Route to alias to true command

  ## Example
      iex> Elirc.Command._alias("bot", %{"bot" => "elirc"})
      "elirc"
  """
  def _alias(command, aliases) do
    case fetch_alias(command, aliases) do
      "" -> command
      value -> value
    end
  end

  def fetch_alias(command, aliases) do
    fetch(command, aliases)
  end

  def fetch_command(command, commands) do
    fetch(command, commands)
  end

  def fetch(key, map) do
    # debug "Fetching #{key}"

    case Map.fetch(map, key) do
      {:ok, value} -> value
      :error -> ""
    end
  end

  @doc """
  Parses a command for the command routing

  ## Examples
      iex> Elirc.Command.parse("hello", %{"hello" => ["say", "Hello"]}, %{})
      ["say", "Hello"]

      iex> Elirc.Command.parse("engage", %{"engage" => ["sound", "engage"]}, %{})
      ["sound", "engage"]

      iex> Elirc.Command.parse("follower", %{"follower" => ["cmd", "follower"]}, %{})
      ["cmd", "follower"]
  """
  def parse(command, commands, aliases \\ %{}) do
    # IO.puts "Parsing command #{command}"

    _alias(command, aliases)
      |> fetch_command(commands)
      # |> IO.inspect
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end