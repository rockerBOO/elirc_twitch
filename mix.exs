defmodule Elirc.Mixfile do
  use Mix.Project

  def project do
    [app: :elirc,
     version: "0.8.0",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :exirc, :quantum, :porcelain, :beaker, :web_socket],
     mod: {Elirc.App, []}]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:quantum, ">= 1.2.4"},
      {:beaker, "~> 0.0.3"},
      {:porcelain, "~> 2.0"},
      {:web_socket, github: "slogsdon/plug-web-socket"},
      {:poolboy, github: "devinus/poolboy"},
      # {:exirc, "~> 0.9.1"},
      {:exirc, github: "bitwalker/exirc"},
      # {:exirc, path: "/home/rockerboo/code/exirc_rockerboo"},
      # {:rest_twitch, git: "git@github.com:rockerBOO/rest_twitch.git"},
      {:rest_twitch, github: "rockerBOO/rest_twitch"},
      # {:rest_twitch, path: "/home/rockerboo/projects/rest_twitch"},
      {:exml, github: "expelledboy/exml"},
      {:timex, "~> 0.12.9"},
      {:socket, "~> 0.2.8"},
      {:expletive, "~> 0.1.0"}
    ]
  end
end
