defmodule Elirc.KeepMeAlive do
  use Supervisor

  @doc """

  ## Examples
  start_link(ExIrc.Client)
  """
  def start_link(client) do
    Supervisor.start_link(__MODULE__, [client], [name: __MODULE__])
  end

  ## Keep these processes alive
  def init([client]) do
    import Supervisor.Spec

    children = [
      worker(Elirc.Channel.Supervisor, [client]),
    ]

    opts = [strategy: :one_for_one,
      name: __MODULE__]

    supervise(children, opts)
  end
end