defmodule Elirc.Extension do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [],
      [name: __MODULE__])
  end

  def init([]) do
    import Supervisor.Spec

    opts = [strategy: :one_for_one, name: __MODULE__]

    # Supervise all extensions
    get_extensions(:message)
      |> get_extensions(:command)
      |> get_extensions(:channel)
      |> workers()
      |> supervise(opts)
  end

  def workers(extensions) do
    extensions
      |> Enum.map(fn (extension) ->
          worker(extension, [self()])
        end)
  end

  @doc """
  Gets extensions and adds to extensions list

  ## Examples
  get_extensions([TwitchExtension], :command)
  """
  def get_extensions(extensions, type) do
    get_extensions(type)
      |> Enum.into(extensions)
  end

  @doc """
  Gets the extensions from the Application

  ## Example
  get_extensions(:message)
  """
  def get_extensions(type) do
    case Application.get_env(:extensions, type) do
      nil -> []
      extensions -> extensions
    end
  end

  @doc """
  Proxy messages to extensions
  """
  def proxy(type, msg) do
    get_extensions(type)
      |> Enum.each(fn (extension) ->
          GenServer.call(extension, msg)
        end)
  end

  def message({msg, user, channel}), do: proxy(:message, {msg, user, channel})
  def command(command), do: proxy(:command, {:cmd, command})
  def joined(user, channel), do: proxy(:channel, {:joined, user})
  def parted(user), do: proxy(:channel, {:parted, user})

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end