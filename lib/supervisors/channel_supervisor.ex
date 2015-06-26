defmodule Elirc.Channel.Supervisor do
  use Supervisor

  def start_link(client) do
    Supervisor.start_link(__MODULE__, [client], [name: Elirc.Channel.Supervisor])
  end

  def channel_to_atom(channel) do
    String.to_atom("channel-" <> channel)
  end

  def new_channel(client, channel) do
    channel_atom = channel_to_atom(channel)

    child_args_spec = [channel, [name: channel_atom]]
    {:ok, pid} = Supervisor.start_child(Elirc.Channel.Supervisor, child_args_spec)

    IO.puts "Starting channel #{channel} for proc_identifier #{channel_atom}"
    IO.inspect pid
  end

  def init([client]) do
    import Supervisor.Spec

    children = [
      # Handles connection actions in IRC
      worker(Elirc.Channel, [client]),
    ]

    opts = [strategy: :simple_one_for_one,
      name: __MODULE__]

    supervise(children, opts)
  end
end