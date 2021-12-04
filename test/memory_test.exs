defmodule ExChip8.MemoryTest do
  use ExUnit.Case

  alias ExChip8.Memory
  alias ExChip8.{Screen, Memory, Registers, Stack, Keyboard}

  describe "Empty memory" do
    test "init/2 initializes memory list" do
      size = 200

      {_, memory, _, _, _} =
        Memory.init({%Screen{}, %Memory{}, %Registers{}, %Stack{}, %Keyboard{}}, size)

      assert length(memory.memory) == size
    end
  end

  describe "Memory operations" do
    setup [:initialize_array]

    test "memory_set/3 sets memory value", %{memory: memory} do
      index = 3
      value = 0xFF
      updated = Memory.memory_set(memory, index, value)
      assert Enum.at(updated.memory, index) == value

      value2 = 0x99
      updated2 = Memory.memory_set(updated, index, value2)
      assert Enum.at(updated2.memory, index) == value2
    end

    test "memory_get_short/2 returns byte from starting index", %{memory: memory} do
      index = 5

      updated =
        memory
        |> Memory.memory_set(index, 0xFF)
        |> Memory.memory_set(index + 1, 0xFF)

      assert Memory.memory_get_short(updated, index) == 0xFFFF

      index2 = 10

      updated2 =
        updated
        |> Memory.memory_set(index2, 0x10)
        |> Memory.memory_set(index2 + 1, 0xAB)

      assert Memory.memory_get_short(updated2, index2) == 0x10AB
    end
  end

  defp initialize_array(_) do
    size = 200

    {_, memory, _, _, _} =
      Memory.init({%Screen{}, %Memory{}, %Registers{}, %Stack{}, %Keyboard{}}, size)

    %{memory: memory}
  end
end
