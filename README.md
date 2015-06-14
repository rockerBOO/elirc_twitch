Elirc
=====

Requires Elixir 

Set the twitch chat key to the environment variables

	export TWITCH_CHAT_KEY=oauth:...

Currently runs in iex

	iex -S mix

Setup the state, modify the `CHANNEL` and `NICK` accordingly

	iex(1)> state = %{host: "irc.twitch.tv", port: 6667, chan: "#CHANNEL", nick: "NICK", sock: nil}

Start up the bot

	iex(2)> Elirc.Bot.start_link(state)
