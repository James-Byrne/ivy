defmodule IvyCamera.MixProject do
  use Mix.Project

  def project do
    [
      app: :ivy_camera,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {IvyCamera.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:picam, "~> 0.4.0"},
      {:plug, "~> 1.8"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.1"}
    ]
  end
end
