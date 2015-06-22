Elirc
=====

In VERY heavy development. Pre-alpha. Risks must be explored at owns peril. Adventure awaits...

Requires Elixir 



Set the twitch chat key to the environment variables. To get [your Twitch chat key](http://twitchapps.com/tmi/).

	export TWITCH_ACCESS_TOKEN=dybd4z...

Currently runs in iex

	iex -S mix


Channels are currently set in `lib/elirc.ex`. `worker(Elirc.Handler.Login, [client, ["#dansgaming"]]),


![Process Flow](https://raw.githubusercontent.com/rockerBOO/elirc_twitch/master/flow.png)