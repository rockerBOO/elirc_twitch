use Mix.Config

config :twitch, access_token: System.get_env("TWITCH_ACCESS_TOKEN"),
                username: System.get_env("TWITCH_USERNAME"),
                channels: [
                    {"#rockerboo", %{noisy?: true}},
                    {"#dansgaming", %{noisy?: false}},
                    # {"#tysonrk", %{noisy?: false}},
                    # {"#riotgames", %{noisy?: false}},
                    # {"#starladder1", %{noisy?: false}},
                    # {"#summit1g", %{noisy?: false}},
                    # {"#arteezy", %{noisy?: false}},
                    # {"#starladder_hs_en", %{noisy?: false}},
                    # {"#summonersinnlive", %{noisy?: false}},
                    # {"#sodapoppin", %{noisy?: false}},
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

config :extend, extensions: [ConnectionExtension]