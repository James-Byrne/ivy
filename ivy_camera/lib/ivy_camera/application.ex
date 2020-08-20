defmodule IvyCamera.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: IvyCamera.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  def children do
    [
      {Picam.Camera, []},
      {IvyCamera.Camera, []},
    ]
  end
end
