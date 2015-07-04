defmodule Elirc.Extension.Channel do
  defmacro __using__(_) do
    quote do
      defp joined({user, channel}), do: {user, channel}

      defp parted({user, channel}), do: {user, channel}

      defp logon({user, channel}), do: {user, channel}

      defp names({channel, names}), do: {channel, names}

      def handle_call({:joined, {user, channel}}, _from, state) do
        {:reply, joined({user, channel}), state}
      end

      def handle_call({:parted, {user, channel}}, _from, state) do
        {:reply, parted({user, channel}), state}
      end

      def handle_call({:logon, {user, channel}}, _from, state) do
        {:reply, logon({user, channel}), state}
      end

      def handle_call({:names, {channel, names}}, _from, state) do
        {:reply, names({channel, names}), state}
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
