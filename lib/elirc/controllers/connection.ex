defmodule Elirc.ConnectionController do
  def echo(:init, state) do
    IO.puts "init"

    {:ok, state}
  end

  def echo(:terminate, _state) do
    IO.puts "terminate"

    :ok
  end

  #rockerboo msg: msg
  def echo("channel_ts", state, channel) do
    IO.puts "Channel lookup:"
    IO.inspect channel

    ts = Beaker.TimeSeries.get(channel)
      |> time_series_to_map(channel)

    resp = case ts do
      nil -> "No data yet!"
      val -> [Poison.encode!(val)]
    end

    IO.puts "Response to channel_ts"
    IO.inspect resp

    {:reply, {:text, resp}, state}
  end

  def echo("channel_latest", state, channel) do
    IO.puts "Channel lookup:"
    IO.inspect channel

    resp = case Beaker.TimeSeries.get(channel) do
      nil -> "No data yet!"
      val -> Enum.fetch!(val, 0) |> plot_time_series()
    end

    IO.puts "Response to channel_ts"
    IO.inspect resp

    {:reply, {:text, resp}, state}
  end

  def to_firespray(values, channel) do
    %{name: channel, color: "skyblue", values: values}
  end

  def plot_time_series({time, amount}) do
    %{x: time, y: amount}
  end

  def time_series_to_map(nil, _), do: []

  def time_series_to_map(ts, channel) do
    Enum.map(ts, &plot_time_series(&1))
      |> to_firespray(channel)
  end

  #rockerboo msg: msg
  def echo("msg", state, data) do
    # IO.inspect data

    {:reply, {:text, "Hamburgers OMG!"}, state}
  end

  def echo(msg, state, data) do
    IO.puts "catch_all"
    IO.inspect data
    IO.inspect msg

    {:reply, {:text, ""}, state}
  end

  def echo(message, state) do
    # IO.inspect message

    {:reply, {:text, message}, state}
  end
end