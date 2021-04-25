defmodule ExChip8.MemoryTest do
  use ExUnit.Case

  alias ExChip8.Memory
  alias ExChip8.State

  describe "Empty memory" do
    test "init/1 initializes memory list" do
      size = 200
      state = Memory.init(%State{}, size)
      assert length(state.memory.memory) == size
    end
  end

  describe "Memory operations" do
    setup [:initialize_array]

    test "memory_set/3 sets memory value", %{memory: memory} do
      index = 3
      value = 0xff
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
        |> Memory.memory_set(index, 0xff)
        |> Memory.memory_set(index + 1, 0xff)

      assert Memory.memory_get_short(updated, index) == 0xffff

      index2 = 10
      updated2 =
        updated
        |> Memory.memory_set(index2, 0x10)
        |> Memory.memory_set(index2 + 1, 0xab)

      assert Memory.memory_get_short(updated2, index2) == 0x10ab

    end
  end

  defp initialize_array _ do
    size = 200
    state = Memory.init(%State{}, size)
    %{memory: state.memory}
  end
end
