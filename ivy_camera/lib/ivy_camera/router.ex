defmodule IvyCamera.Router do
  use Plug.Router

  # Allow JSON responses/requests
  plug Plug.Parsers, parsers: [:json], pass: ["text/*"], json_decoder: Jason

  # These are included for us and match the incoming
  # request to a function and invoke it respectively.
  plug :match
  plug :dispatch

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  post "/start" do
    send_resp(conn, 200, "start recieved")
  end

  forward "/live_stream.mjpg", to: IvyCamera.Routes.Streams.Live
  forward "/delayed_stream.mjpg", to: IvyCamera.Routes.Streams.Delayed

  match _ do
    send_resp(conn, 404, "Oh no! What you seek cannot be found.")
  end
end
