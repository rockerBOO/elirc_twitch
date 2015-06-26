defmodule Elirc.SoundPool.Worker do
  alias Elirc.Sound

  def start_link(sound_list) do
    GenServer.start_link(__MODULE__, [sound_list], [])
  end

  def init([sound_list]) do
    {:ok, %{sounds: sound_list}}
  end

  @doc """
  Handles calls to play the sound
  """
  def handle_call({:play, sound}, _from, state) do
    reply = Sound.play(sound, state.sounds)

    {:reply, reply, state}
  end

  def handle_info(reason, state) do
    {:noreply, state}
  end

  def terminate(reason, _state) do
    IO.inspect reason
    :ok
  end
end