defmodule Elirc.Channel.Supervisor do
  use Supervisor

  alias Elirc.Channel

  @doc """
  Starts the supervisor of the channels

  ## Examples
  start_link(ExIrc.Client)
  """
  def start_link(client) do
    Supervisor.start_link(__MODULE__, [client], [name: Elirc.Channel.Supervisor])
  end

  @doc """
  Starts a new supervised process for the channel

  ## Examples
  start_channel("#test_channel", %{noisy?: false})
  """
  def start_channel(channel, opts) do
    # IO.puts "start_channel #{channel}"

    process_opts = [channel, opts, [name: Channel.to_atom(channel)]]
    Supervisor.start_child(Elirc.Channel.Supervisor, process_opts)
  end

  @doc """
  Starts a new Elirc.Channel
  """
  def new!(channel, opts \\ %{}) do
    case new(channel, opts) do
      {:ok, pid} -> pid
      {:error, error} -> raise error
    end
  end

  def new(channel, opts \\ %{}), do: start_channel(channel, opts)

  def init([client]) do
    import Supervisor.Spec

    children = [
      worker(Elirc.Channel, [client]),
    ]

    opts = [strategy: :simple_one_for_one,
      name: __MODULE__]

    supervise(children, opts)
  end
end