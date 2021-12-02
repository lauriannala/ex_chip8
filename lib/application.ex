defmodule ExChip8.Application do
  def start(_type, _args) do
    main_viewport_config = Application.get_env(:ex_chip8, :viewport)

    children = [
      {Scenic, viewports: [main_viewport_config]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
