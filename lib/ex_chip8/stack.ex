defmodule ExChip8.Stack do
  alias ExChip8.Registers
  alias ExChip8.StateServer

  def init({screen, memory, registers, stack, keyboard}, size) do
    0..(size - 1)
    |> Enum.with_index()
    |> Enum.each(fn {_, index} ->
      insert_stack(index, 0x00)
    end)

    {screen, memory, registers, stack, keyboard}
  end

  def insert_stack(index, value) when is_integer(index) and is_integer(value) do
    GenServer.call(StateServer, {:insert_stack, index, value})
  end

  def lookup_stack(index) when is_integer(index) do
    [{^index, value}] = GenServer.call(StateServer, {:lookup_stack, index})
    value
  end

  def stack_push({stack, registers}, value) do
    sp = Registers.lookup_register(:sp)

    if sp + 1 >= :ets.info(:stack)[:size],
      do: raise("Stack pointer out of bounds.")

    insert_stack(sp, value)

    Registers.insert_register(:sp, sp + 1)
    {stack, registers}
  end

  def stack_pop({_, registers}) do
    sp = Registers.lookup_register(:sp)
    Registers.insert_register(:sp, sp - 1)

    {registers, Registers.lookup_register(:sp) |> lookup_stack()}
  end
end
