 use Mix.Config

config :twitch,
  channels: [
    {"#rockerboo", %{noisy?: true}},
    {"#lirik", %{noisy?: false}},
    {"#arteezy", %{noisy?: false}},
    {"#tsm_theoddone", %{noisy?: false}},
    {"#trumpsc", %{noisy?: false}},
    {"#summit1g", %{noisy?: false}},
    {"#pokercentral", %{noisy?: false}},
    {"#pashabiceps", %{noisy?: false}},
    {"#wingsofdeath", %{noisy?: false}},
    {"#pietsmiet", %{noisy?: false}},
    {"#hail9", %{noisy?: false}},
    {"#fairlight_excalibur", %{noisy?: false}},
    {"#trick2g", %{noisy?: false}},
  ]

config :extensions,
  message: [TwitchExtension],
  command: [TwitchCommand],
  channel: [TwitchChannel]