
defmodule Elirc.App do
  @moduledoc """
  Entry point for the ExIrc application.
  """
  use Application

  def start(_type, _args) do
    Elirc.start _type, _args
  end
end