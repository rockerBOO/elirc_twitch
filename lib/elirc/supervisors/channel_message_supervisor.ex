defmodule Elirc.ChannelMessage.Supervisor do
  use Supervisor

  alias Elirc.Channel

  @doc """
  Starts the supervisor of the channel message processors

  ## Examples
  start_link(channel)
  """
  def start_link(channel) do
    Supervisor.start_link(__MODULE__, [channel],
      [name: Elirc.Channel.Supervisor]
    )
  end

  def init([channel]) do
    import Supervisor.Spec

    IO.puts "Initializing"

    children = [
      worker(Elirc.MessageQueue.Supervisor, [channel]),
      worker(Elirc.MessagePool.Supervisor, [channel]),
      worker(Elirc.CommandPool.Supervisor, [channel]),
      worker(Elirc.SoundPool.Supervisor, [channel]),
    ]

    opts = [strategy: :one_for_one,
      name: __MODULE__]

    supervise(children, opts)
  end
end