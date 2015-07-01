Elirc
=====

![Build Status](https://travis-ci.org/rockerBOO/elirc_twitch.svg?branch=master)

Elirc is a Twitch Chat Bot that strives for complete failure control, and the ability to handle any amount of messages coming in.

In VERY heavy development. Pre-alpha. Risks must be explored at owns peril. Adventure awaits...

## Configuration

You will need to set the following environmental variables.

Create a `.env` (ex: [.env.example](https://github.com/rockerBOO/elirc_twitch/blob/master/.env.example)) file in your project with the following content:

* `TWITCH_ACCESS_TOKEN`
* `TWITCH_USERNAME`

To get [your a Twitch Chat Key](http://twitchapps.com/tmi/).

*NOTE* The chat key only is scoped for "chat_login" and won't work with [RestTwitch](http://github.com/rockerboo/rest_twitch) intergration without "user_read" scope. I have created the [rockerBOO/elirc_twitch_oauth_web](https://github.com/rockerBOO/elirc_twitch_oauth_web) project to allow you to get a scoped OAuth.

### RestTwitch Requirement

* `TWITCH_CLIENT_ID`
* `TWITCH_CLIENT_SECRET`
* `TWITCH_REDIRECT_URI`

Then **run `source .env`** in your shell before compiling your project.

## Usage

Currently runs in iex

	iex -S mix

## Process flow

![Process Flow](https://raw.githubusercontent.com/rockerBOO/elirc_twitch/master/flow.png)

## Project Throughput

[![Throughput Graph](https://graphs.waffle.io/rockerboo/elirc_twitch/throughput.svg)](https://waffle.io/rockerboo/elirc_twitch/metrics)