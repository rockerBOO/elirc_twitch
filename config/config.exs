use Mix.Config

config :twitch, access_token: System.get_env("TWITCH_ACCESS_TOKEN"),
                username: System.get_env("TWITCH_USERNAME"),
                channels: [
                    {"#rockerboo", %{noisy?: true}},
                    # {"#jonbams", %{noisy?: false}},
                    # {"#siegegames", %{noisy?: false}},
                    # {"#sevadus", %{noisy?: false}},
                    # {"#riotgames", %{noisy?: false}},
                    # {"#starladder1", %{noisy?: false}},
                    # {"#wcs", %{noisy?: false}},
                    # {"#gfinitytv", %{noisy?: false}},
                    # {"#lirik", %{noisy?: false}},
                    # {"#gronkh", %{noisy?: false}},
                    # {"#ogaminglol", %{noisy?: false}},
                    # {"#castro_1021", %{noisy?: false}},
                    # {"#reynad27", %{noisy?: false}},
                    # {"#trumpsc", %{noisy?: false}},
                    # {"#esportal", %{noisy?: false}},
                    # {"#smitegame", %{noisy?: false}},
                    # {"#startladder_hs_ru", %{noisy?: false}},
                    # {"#helenalive", %{noisy?: false}},
                    # {"#nerdist", %{noisy?: false}}
                  ]

config :extend, extensions: [Elirc.ConnectionExtension]