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

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_termbox, "~> 0.3"}
    ]
  end

  defp aliases do
    [
      ex_chip8: ["run lib/ex_chip8.exs"]
    ]
  end
end
