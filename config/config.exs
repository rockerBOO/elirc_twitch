use Mix.Config

config :twitch,
  access_token: System.get_env("TWITCH_ACCESS_TOKEN"),
  username: System.get_env("TWITCH_USERNAME"),
  channels: [
    {"#rockerboo", %{noisy?: true}},
    {"#wcs", %{noisy?: false}},
    {"#nightblue3", %{noisy?: false}},
    {"#riotgamesbrazil", %{noisy?: false}},
    {"#riotgames", %{noisy?: false}},
    {"#starladder1", %{noisy?: false}},
    {"#wcs", %{noisy?: false}},
    {"#gfinitytv", %{noisy?: false}},
    {"#lirik", %{noisy?: false}},
    {"#forsenlol", %{noisy?: false}},
    {"#ogaminglol", %{noisy?: false}},
    {"#castro_1021", %{noisy?: false}},
    {"#riotgames", %{noisy?: false}},
    {"#voyboy", %{noisy?: false}},
    {"#esportal", %{noisy?: false}},
    {"#smitegame", %{noisy?: false}},
    {"#sing_sing", %{noisy?: false}},
    {"#ezekiel_iii", %{noisy?: false}},
    {"#sodapoppin", %{noisy?: false}}
  ]

config :extensions,
  message: [TwitchExtension],
  command: [TwitchCommand],
  channel: [TwitchChannel]