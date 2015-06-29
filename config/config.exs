use Mix.Config

config :twitch,
  access_token: System.get_env("TWITCH_ACCESS_TOKEN"),
  username: System.get_env("TWITCH_USERNAME"),
  channels: [
    {"#rockerboo", %{noisy?: true}},
    {"#capcomfighters", %{noisy?: false}},
    {"#arteezy", %{noisy?: false}},
    {"#trumpsc", %{noisy?: false}},
    {"#trick2g", %{noisy?: false}},
    {"#summit1g", %{noisy?: false}},
    {"#stonedyooda", %{noisy?: false}},
    {"#sodapoppin", %{noisy?: false}},
    {"#syndicate", %{noisy?: false}},
    {"#scarra", %{noisy?: false}},
    {"#sing_sing", %{noisy?: false}},
    {"#tsm_wildturtle", %{noisy?: false}},
    {"#joshog", %{noisy?: false}},
  ]

config :extensions,
  message: [TwitchExtension],
  command: [TwitchCommand],
  channel: [TwitchChannel]