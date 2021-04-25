defmodule ExChip8Test do
  use ExUnit.Case

  describe "ExChip8" do
    test "create_state/0 creates state" do
      chip8_width = Application.get_env(:ex_chip8, :chip8_width)
      chip8_height = Application.get_env(:ex_chip8, :chip8_height)
      sleep_wait_period = Application.get_env(:ex_chip8, :sleep_wait_period)
      chip8_memory_size = Application.get_env(:ex_chip8, :chip8_memory_size)
      chip8_total_data_registers = Application.get_env(:ex_chip8, :chip8_total_data_registers)

      state = ExChip8.create_state()
      assert state.screen.sleep_wait_period == sleep_wait_period
      assert state.screen.chip8_height == chip8_height
      assert state.screen.chip8_width == chip8_width

      assert length(state.memory.memory) == chip8_memory_size

      assert length(state.registers.v) == chip8_total_data_registers
    end
  end
end
