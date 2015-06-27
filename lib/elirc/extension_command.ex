defmodule Elirc.Extension.Command do
  defmacro __using__(_) do
    quote do
      defp command({command, channel}), do: {command, channel}

      defp sound({sound, channel}), do: {sound, channel}

      def handle_call({:command, {command, channel}}, _from, state) do
        {:reply, command({user, channel}), state}
      end

      def handle_call({:sound, {sound, channel}}, _from, state) do
        {:reply, sound({sound, channel}), state}
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
