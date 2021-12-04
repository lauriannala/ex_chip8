defmodule ExChip8.Memory do
  alias ExChip8.Memory
  import Bitwise

  defstruct memory: []

  def init({sreen, _, registers, stack, keyboard}, size) do
    memory = %Memory{
      memory: 0..(size - 1) |> Enum.map(fn _ -> 0x00 end)
    }

    {sreen, memory, registers, stack, keyboard}
  end

  def memory_set(%Memory{} = memory, index, value) do
    set = List.replace_at(memory.memory, index, value)
    Map.put(memory, :memory, set)
  end

  def memory_get(%Memory{} = memory, index) do
    Enum.at(memory.memory, index)
  end

  def memory_get_short(%Memory{} = memory, index) do
    byte1 = memory_get(memory, index)
    byte2 = memory_get(memory, index + 1)

    byte1 <<< 8 ||| byte2
  end
end
