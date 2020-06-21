defmodule IvyCamera.Routes.Streams.Live do
  @moduledoc """
  Plug for streaming live images (mjpg)
  """

  import Plug.Conn

  @behaviour Plug
  @boundary "w58EW1cEpjzydSCq"

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header("Age", "0")
    |> put_resp_header("Cache-Control", "no-cache, private")
    |> put_resp_header("Pragma", "no-cache")
    |> put_resp_header("Content-Type", "multipart/x-mixed-replace; boundary=#{@boundary}")
    |> send_chunked(200)
    |> send_pictures
  end

  defp send_pictures(conn) do
    {:ok, picture} = GenServer.call(IvyCamera.Camera, {:next_frame, :live})

    conn
    |> send_picture(picture)
    |> case do
      {:ok, conn} -> send_pictures(conn)
      error -> error
    end
  end

  defp send_picture(conn, picture) do
    header = "------#{@boundary}\r\nContent-Type: image/jpeg\r\nContent-length: #{byte_size(picture)}\r\n\r\n"
    footer = "\r\n"
    with {:ok, conn} <- chunk(conn, header),
         {:ok, conn} <- chunk(conn, picture),
         {:ok, conn} <- chunk(conn, footer),
         do: {:ok, conn}
  end
end
