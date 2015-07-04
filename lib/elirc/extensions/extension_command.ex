defmodule Elirc.Extension.Command do
  defmacro __using__(_) do
    quote do
      defp command({command, channel, user, config}) do
        {command, channel, user, config}
      end

      defp sound({sound, channel}) do
        {sound, channel}
      end

      def handle_call({:cmd, {command, channel, user, config}}, _from, state) do
        {:reply, command({command, channel, user, config}), state}
      end

      def handle_call({:sound, {sound, channel}}, _from, state) do
        {:reply, sound({sound, channel}), state}
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
