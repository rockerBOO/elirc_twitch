 use Mix.Config

config :twitch,
  channels: [
    {"#rockerboo", %{noisy?: true}},
    {"#mojang", %{noisy?: false}},
  ]

config :extensions,
  message: [TwitchExtension],
  command: [TwitchCommand],
  channel: [TwitchChannel]