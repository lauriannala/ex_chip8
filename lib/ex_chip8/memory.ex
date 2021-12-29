defmodule ExChip8.Memory do
  alias ExChip8.StateServer
  import Bitwise

  @moduledoc """
  Implements methods for retrieving and manipulating memory state from StateServer.
  """

  @doc """
  Initialize memory with specified size.
  """
  @spec init(size :: integer) :: :ok
  def init(size) do
    0..(size - 1)
    |> Enum.each(fn index ->
      insert_memory(index, 0x00)
    end)

    :ok
  end

  @doc """
  Initialize memory with specified values.
  """
  @spec initialize_memory(values :: list(integer)) :: :ok
  def initialize_memory(values) do
    values
    |> Enum.with_index()
    |> Enum.each(fn {value, index} ->
      insert_memory(index, value)
    end)

    :ok
  end

  @doc """
  Get short (two bytes) from memory at specified index.
  """
  @spec memory_get_short(index :: integer) :: integer
  def memory_get_short(index) do
    byte1 = lookup_memory(index)
    byte2 = lookup_memory(index + 1)

    byte1 <<< 8 ||| byte2
  end

  @doc """
  Request server to insert value to memory at specified location.
  """
  @spec insert_memory(at :: integer, value :: integer) :: :ok
  def insert_memory(at, value) when is_integer(at) and is_integer(value) do
    GenServer.call(StateServer, {:insert_memory, at, value})

    :ok
  end

  @doc """
  Request server to retrieve value from specified memory location.
  """
  @spec lookup_memory(at :: integer) :: integer
  def lookup_memory(at) when is_integer(at) do
    [{^at, value}] = GenServer.call(StateServer, {:lookup_memory, at})
    value
  end

  @doc """
  Request server to retrieve all values from memory.

  Values are sorted by memory location index.
  """
  @spec memory_all_values() :: list(integer)
  def memory_all_values() do
    GenServer.call(StateServer, {:memory_all_values})
    |> Enum.sort_by(fn {index, _} -> index end)
    |> Enum.map(fn {_index, value} -> value end)
  end
end
