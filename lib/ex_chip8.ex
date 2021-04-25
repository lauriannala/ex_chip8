defmodule ExChip8 do

  alias ExChip8.State

  @chip8_width Application.get_env(:ex_chip8, :chip8_width)
  @chip8_height Application.get_env(:ex_chip8, :chip8_height)
  @sleep_wait_period Application.get_env(:ex_chip8, :sleep_wait_period)
  @chip8_memory_size Application.get_env(:ex_chip8, :chip8_memory_size)
  @chip8_total_data_registers Application.get_env(:ex_chip8, :chip8_total_data_registers)

  def start() do
    state = create_state()

    ExChip8.Screen.init_screen()

    Stream.cycle([0])
    |> Enum.map(fn _ ->

      ExChip8.Screen.draw(state)

    end)
  end

  def create_state() do
    %State{}
    |> ExChip8.Screen.init_state([
      sleep_wait_period: @sleep_wait_period,
      chip8_height: @chip8_height,
      chip8_width: @chip8_width
    ])
    |> ExChip8.Memory.init(@chip8_memory_size)
    |> ExChip8.Registers.init(@chip8_total_data_registers)
  end
end
