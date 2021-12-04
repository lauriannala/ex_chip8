defmodule ExChip8.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_chip8,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {ExChip8.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:scenic, "~> 0.10"},
      {:scenic_driver_glfw, "~> 0.10", targets: :host}
    ]
  end

  defp aliases do
    [
      game: ["scenic.run"]
    ]
  end
end
