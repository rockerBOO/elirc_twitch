 use Mix.Config

config :twitch,
  access_token: System.get_env("TWITCH_ACCESS_TOKEN"),
  username: System.get_env("TWITCH_USERNAME"),
  channels: [
    {"#rockerboo", %{noisy?: true}},
    {"#nl_kripp", %{noisy?: false}},
    {"#arteezy", %{noisy?: false}},
    {"#bestrivenna", %{noisy?: false}},
    {"#trick2g", %{noisy?: false}},
    {"#fairlight_excalibur", %{noisy?: false}},
    {"#quaslol", %{noisy?: false}},
    {"#europeanspeedstersassembly", %{noisy?: false}},
    {"#hero", %{noisy?: false}},
    {"#sjow", %{noisy?: false}},
    {"#steel_tv", %{noisy?: false}},
    {"#richard_hammer", %{noisy?: false}},
    {"#gratis150ml", %{noisy?: false}},
  ]

config :extensions,
  message: [TwitchExtension],
  command: [TwitchCommand],
  channel: [TwitchChannel]