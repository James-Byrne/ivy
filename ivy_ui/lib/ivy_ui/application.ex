defmodule IvyUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      IvyUiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: IvyUi.PubSub},
      # Start the Endpoint (http/https)
      IvyUiWeb.Endpoint
      # Start a worker by calling: IvyUi.Worker.start_link(arg)
      # {IvyUi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: IvyUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    IvyUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
