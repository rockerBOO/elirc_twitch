defmodule Github.Command do
  use Elirc.Extension.Command
  alias Elirc.Message
  alias Elirc.Command
  alias Elirc.Sound
  alias Elirc.Emoticon

  def start_link(ext) do
    GenServer.start_link(__MODULE__, [ext], [name: __MODULE__])
  end

  def init([ext]) do
    {:ok, [ext]}
  end

  @doc """
  Gets the last follower to the channel

  ## Examples
  Elirc.Command.get_last_follower()
  """
  def get_last_follower() do
    # GithubAuth
  end

end