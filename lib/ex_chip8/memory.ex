defmodule ExChip8.Memory do
  alias ExChip8.StateServer
  import Bitwise

  def init(size) do
    0..(size - 1)
    |> Enum.each(fn index ->
      insert_memory(index, 0x00)
    end)
  end

  def initialize_memory(values) do
    values
    |> Enum.with_index()
    |> Enum.each(fn {value, index} ->
      insert_memory(index, value)
    end)
  end

  def memory_get_short(index) do
    byte1 = lookup_memory(index)
    byte2 = lookup_memory(index + 1)

    byte1 <<< 8 ||| byte2
  end

  def insert_memory(at, value) when is_integer(at) and is_integer(value) do
    GenServer.call(StateServer, {:insert_memory, at, value})
  end

  def lookup_memory(at) when is_integer(at) do
    [{^at, value}] = GenServer.call(StateServer, {:lookup_memory, at})
    value
  end

  def memory_all_values() do
    GenServer.call(StateServer, {:memory_all_values})
    |> Enum.sort_by(fn {index, _} -> index end)
    |> Enum.map(fn {_index, value} -> value end)
  end
end
