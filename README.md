Elirc
=====

![Build Status](https://travis-ci.org/rockerBOO/elirc_twitch.svg?branch=master)

In VERY heavy development. Pre-alpha. Risks must be explored at owns peril. Adventure awaits...

Requires Elixir

## Configuration


You will need to set the following configuration variables in your
`config/config.exs` file:

```elixir
use Mix.Config

config :twitch, access_token: System.get_env("TWITCH_ACCESS_TOKEN"),
                   username:  System.get_env("TWITCH_USERNAME")
```

Set the twitch access token to the environment variables. To get [your Twitch chat key](http://twitchapps.com/tmi/). The chat key only is scoped for "chat_login" and won't work with RestTwitch intergration without "user_read" scope.

For security, I recommend that you use environment variables rather than hard
coding your account credentials. If you don't already have an environment
variable manager, you can create a `.env` file in your project with the
following content:

```bash
export TWITCH_ACCESS_TOKEN=dybd4z...
export TWITCH_USERNAME=your_username
```

Then, just be sure to run `source .env` in your shell before compiling your
project.

## Usage

Currently runs in iex

	iex -S mix


## Process flow

![Process Flow](https://raw.githubusercontent.com/rockerBOO/elirc_twitch/master/flow.png)