defmodule ExChip8.Stack do
  alias ExChip8.Registers
  use ExChip8.State

  @moduledoc """
  Implements methods for retrieving and manipulating stack data from StateServer.
  """

  @doc """
  Initialize stack with specified size.
  """
  @spec init(size :: integer) :: :ok
  def init(size) do
    0..(size - 1)
    |> Enum.with_index()
    |> Enum.each(fn {_, index} ->
      insert_stack(index, 0x00)
    end)

    :ok
  end

  @doc """
  Request server to insert value to stack at specified index.
  """
  @spec insert_stack(index :: integer, value :: integer) :: :ok
  def insert_stack(index, value) when is_integer(index) and is_integer(value) do
    :ets.insert(@stack, {index, value})

    :ok
  end

  @doc """
  Request server to lookup for value from stack at specified index.
  """
  @spec lookup_stack(index :: integer) :: integer
  def lookup_stack(index) when is_integer(index) do
    [{^index, value}] = :ets.lookup(@stack, index)
    value
  end

  @doc """
  Push value to stack.

  Value is inserted to location specified by stack pointer register.
  After insertion, stack pointer register value is incremented.
  """
  @spec stack_push(value :: integer) :: :ok
  def stack_push(value) do
    sp = Registers.lookup_register(:sp)

    if sp + 1 >= :ets.info(:stack)[:size],
      do: raise("Stack pointer out of bounds.")

    insert_stack(sp, value)

    Registers.insert_register(:sp, sp + 1)

    :ok
  end

  @doc """
  Pop value from stack.

  Stack pointer register is decremented.
  After decrement, value is retrieved from stack from location specified by stack pointer.
  """
  @spec stack_pop() :: integer
  def stack_pop() do
    sp = Registers.lookup_register(:sp)
    Registers.insert_register(:sp, sp - 1)

    Registers.lookup_register(:sp) |> lookup_stack()
  end
end
