defmodule Elirc.Extension do
  use GenEvent
  use GenServer

  defmodule State do
    defstruct [
      :ext,
      :event_handlers
    ]
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    {:ok, %State{}}
  end

  def start_extensions() do
    Application.get_env(:extend, :extensions)
      |> Enum.each(fn (extension) -> start_handler(extension) end)
  end

  defp start_handler(handler) do
    IO.puts "start_handler #{IO.inspect handler}"
    handler.start_link(self)
  end

  def add_handler(ext, pid) do
    IO.puts "add_handler"
    IO.inspect ext
    IO.inspect pid
    :gen_server.call(ext, {:add_handler, pid})
  end

  def handle_info(info, state) do
    # send_event(info, state)
    {:noreply, state}
  end

  def handle_call(:start, _from, state) do
    start_extensions()
  end

  def handle_call({:add_handler, pid}, _from, state) do
    IO.puts ":add_handler"
    IO.inspect pid
    # handlers = do_add_handler(pid, state.event_handlers)
    # {:reply, :ok, %{state | :event_handlers => handlers}}
    {:reply, :ok, state}
  end

  def handle_call(call, _from, state) do
    IO.puts "WTF"
    {:reply, :ok, state}
  end

  defp send_event(msg, %State{:event_handlers => handlers}) when is_list(handlers) do
    Enum.each(handlers, fn({pid, _}) -> GenEvent.notify(pid, msg) end)
  end

  defp do_add_handler(pid, handlers) do
    case Enum.member?(handlers, pid) do
      false ->
        ref = Process.monitor(pid)
        [{pid, ref} | handlers]
      true ->
        handlers
    end
  end

  defp do_remove_handler(pid, handlers) do
    case List.keyfind(handlers, pid, 0) do
      {pid, ref} ->
        Process.demonitor(ref)
        List.keydelete(handlers, pid, 0)
      nil ->
        handlers
    end
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end