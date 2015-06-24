defmodule Elirc.SoundPool.Worker do
  alias Elirc.Message

  def start_link(sound_list) do
    GenServer.start_link(__MODULE__, [sound_list], [])
  end

  def init([sound_list]) do
    {:ok, %{sounds: sound_list}}
  end

  def handle_call({:play, sound}, _from, state) do
    Elirc.Sound.play(sound, state)

    {:reply, :ok, state}
  end

  def handle_info(reason, state) do
    IO.inspect reason

    {:noreply, state}
  end

  def terminate(reason, state) do
    IO.inspect reason
    :ok
  end
end