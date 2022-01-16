defmodule Mix.Tasks.ExChip8.Run do
  use Mix.Task

  require Logger

  @shortdoc "Starts the UI application"

  @moduledoc """
  Starts the application

  The `--no-halt` flag is automatically added.
  """

  @doc false
  @impl Mix.Task
  def run(args) do
    Logger.info("Started chip8 emulator application.")

    Mix.Tasks.Run.run(run_args() ++ args)
  end

  defp run_args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?()
  end
end
