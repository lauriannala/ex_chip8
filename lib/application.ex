defmodule ExChip8.Application do
  @env Application.get_env(:ex_chip8, :env)
  @main_viewport_config Application.get_env(:ex_chip8, :viewport)

  def start(_type, _args) do
    Supervisor.start_link(children(@env), strategy: :one_for_one)
  end

  def children(:test) do
    []
  end

  def children(_) do
    [
      {Scenic, viewports: [@main_viewport_config]},
      ExChip8.StateServer
    ]
  end
end
