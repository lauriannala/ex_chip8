defmodule ExChip8Test do
  use ExUnit.Case

  alias ExChip8.State

  describe "ExChip8 uninitialized" do
    test "create_state/0 creates state" do
      chip8_width = Application.get_env(:ex_chip8, :chip8_width)
      chip8_height = Application.get_env(:ex_chip8, :chip8_height)
      sleep_wait_period = Application.get_env(:ex_chip8, :sleep_wait_period)
      chip8_memory_size = Application.get_env(:ex_chip8, :chip8_memory_size)
      chip8_total_data_registers = Application.get_env(:ex_chip8, :chip8_total_data_registers)

      state = ExChip8.create_state(%State{})
      assert state.screen.sleep_wait_period == sleep_wait_period
      assert state.screen.chip8_height == chip8_height
      assert state.screen.chip8_width == chip8_width

      assert length(state.memory.memory) == chip8_memory_size

      assert length(state.registers.v) == chip8_total_data_registers
    end
  end

  describe "ExChip8 with state" do
    setup [:with_state]

    test "init/1 sets keyboard_map to memory", %{state: state} do
      keyboard_map = [
        ?0, ?1, ?2, ?3
      ]
      original_length = length(state.memory.memory)
      state = ExChip8.init(state, keyboard_map)

      assert Enum.slice(state.memory.memory, 0..3) ==
        keyboard_map
      assert Enum.slice(state.memory.memory, 4, length(state.memory.memory)) |> Enum.all?(fn x -> x == 0x00 end)
      assert original_length == length(state.memory.memory)
    end
  end

  defp with_state(_) do
    state = ExChip8.create_state(%State{})
    %{state: state}
  end
end
