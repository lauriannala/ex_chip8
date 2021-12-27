defmodule ExChip8Test do
  use ExUnit.Case

  alias ExChip8
  alias ExChip8.{Screen, Memory, Stack, Keyboard}

  describe "ExChip8 uninitialized" do
    test "create_state/0 creates state" do
      chip8_width = Application.get_env(:ex_chip8, :chip8_width)
      chip8_height = Application.get_env(:ex_chip8, :chip8_height)
      sleep_wait_period = Application.get_env(:ex_chip8, :sleep_wait_period)
      chip8_memory_size = Application.get_env(:ex_chip8, :chip8_memory_size)
      chip8_total_data_registers = Application.get_env(:ex_chip8, :chip8_total_data_registers)

      {:ok, {screen, memory, _, _, _}, _} =
        ExChip8.create_state({%Screen{}, %Memory{}, nil, %Stack{}, %Keyboard{}})

      assert screen.sleep_wait_period == sleep_wait_period
      assert screen.chip8_height == chip8_height
      assert screen.chip8_width == chip8_width

      assert length(memory.memory) == chip8_memory_size

      assert :ets.info(:v_register)[:size] == chip8_total_data_registers
    end
  end

  describe "ExChip8 with state" do
    setup [:with_state]

    test "init/1 sets character_set to memory", %{state: {:ok, {_, memory, _, _, _}, _} = state} do
      character_set = [
        0xF0,
        0x90,
        0x90,
        0x90
      ]

      original_length = length(memory.memory)

      {:ok, {_, memory, _, _, _}, _} = ExChip8.init(state, character_set)

      assert Enum.slice(memory.memory, 0..3) ==
               character_set

      assert Enum.slice(memory.memory, 4, length(memory.memory))
             |> Enum.all?(fn x -> x == 0x00 end)

      assert original_length == length(memory.memory)
    end
  end

  defp with_state(_) do
    state = ExChip8.create_state({%Screen{}, %Memory{}, nil, %Stack{}, %Keyboard{}})
    %{state: state}
  end
end
