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
  def start_channel(channel, details \\ %{}) do
    channel_atom = Channel.to_atom(channel)

    process_opts = [channel, [name: channel_atom]]
    Supervisor.start_child(Elirc.Channel.Supervisor, process_opts)
  end

  @doc """
  Starts a new Elirc.Channel
  """
  def new(channel, details \\ %{}) do
    start_channel(channel, details)
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