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
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end

  defp aliases do
    [
      ex_chip8: ["run lib/main.exs"]
    ]
  end
end
