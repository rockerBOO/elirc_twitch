defmodule Elirc.Extension.Message do
  defmacro __using__(_) do
    quote do
      defp message({msg, user, channel}), do: msg

      defp emotes(emotes), do: emotes

      defp words(words), do: words

      defp spam(spam), do: spam

      defp command(command), do: command

      def handle_call({:msg, {msg, user, channel}}, _from, state) do
        {:reply, message({msg, user, channel}), state}
      end

      def handle_call({:emote, {emotes, channel}}, _from, state) do
        {:reply, emotes({emotes, channel}), state}
      end

      def handle_call({:words, {words, channel}}, _from, state) do
        {:reply, words({words, channel}), state}
      end

      def handle_call({:spam, {message, channel}}, _from, state) do
        {:reply, spam({message, channel}), state}
      end

      def handle_call({:cmd, {msg, user, channel}}, _from, state) do
        {:reply, message({msg, user, channel}), state}
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
