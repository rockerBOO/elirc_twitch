defmodule Elirc.Mixfile do
  use Mix.Project

  def project do
    [app: :elirc,
     version: "0.0.1",
     elixir: "~> 1.0-dev",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :exirc, :quantum],
     mod: {Elirc.App, []}]
  end

  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:quantum, ">= 1.2.4"},
      {:poolboy, github: "devinus/poolboy"},
      # {:exirc, "~> 0.9.1"},
      {:exirc, github: "bitwalker/exirc"},
      # {:exirc, path: "/home/rockerboo/code/exirc_rockerboo"},
      {:rest_twitch, github: "rockerboo/rest_twitch"},
      # {:rest_twitch, path: "/home/rockerboo/projects/rest_twitch"},
      {:exml, github: "expelledboy/exml"},
      {:timex, "~> 0.12.9"},
      {:socket, "~> 0.2.8"}
    ]
  end
end
