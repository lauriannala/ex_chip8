defmodule ExChip8.MemoryTest do
  use ExChip8.StateCase

  alias ExChip8.Memory
  alias ExChip8.{Screen, Memory, Keyboard}

  describe "Empty memory" do
    test "init/2 initializes memory list" do
      size = 200

      {_, _, _, _, _} = Memory.init({%Screen{}, nil, nil, nil, %Keyboard{}}, size)

      assert size == :ets.info(:memory)[:size]
    end
  end

  describe "Memory operations" do
    setup [:initialize_array]

    test "memory_set/3 sets memory value", _ do
      index = 3
      value = 0xFF
      Memory.insert_memory(index, value)
      assert Memory.lookup_memory(index) == value

      value2 = 0x99
      Memory.insert_memory(index, value2)
      assert Memory.lookup_memory(index) == value2
    end

    test "memory_get_short/2 returns byte from starting index", _ do
      index = 5

      Memory.insert_memory(index, 0xFF)
      Memory.insert_memory(index + 1, 0xFF)

      assert Memory.memory_get_short(index) == 0xFFFF

      index2 = 10

      Memory.insert_memory(index2, 0x10)
      Memory.insert_memory(index2 + 1, 0xAB)

      assert Memory.memory_get_short(index2) == 0x10AB
    end
  end

  defp initialize_array(_) do
    size = 200

    {_, _, _, _, _} = Memory.init({%Screen{}, nil, nil, nil, %Keyboard{}}, size)

    %{memory: nil}
  end
end
