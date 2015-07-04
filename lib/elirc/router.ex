defmodule Elirc.WebSocket.Router do
  use Plug.Router
  use WebSocket

  # WebSocket routes
  #      route     controller/handler     function & name
  socket "/bot", Elirc.BotController, :msg

  plug :match
  plug :dispatch

  get "/" do
    data = "priv/static/menu.html"
      |> Path.expand
      |> File.read!
    conn |> send_resp(200, data)
  end

  match _ do
    conn |> send_resp(404, "Not Found")
  end

  # Start Cowboy Server on this port
  @port 4050
  def start do
    Plug.Adapters.Cowboy.http Elirc.WebSocket.Router, [], port: @port
  end
end