defmodule ExChip8 do

  @chip8_width Application.get_env(:ex_chip8, :chip8_width)
  @chip8_height Application.get_env(:ex_chip8, :chip8_height)
  @sleep_wait_period Application.get_env(:ex_chip8, :sleep_wait_period)

  def start() do
    state = ExChip8.Screen.init(%{
      sleep_wait_period: @sleep_wait_period,
      chip8_height: @chip8_height,
      chip8_width: @chip8_width
    })

    Stream.cycle([0])
    |> Enum.map(fn _ ->

      ExChip8.Screen.draw(state)

    end)
  end
end

ExChip8.start()
