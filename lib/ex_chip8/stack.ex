defmodule ExChip8.Stack do
  alias ExChip8.Stack
  alias ExChip8.Registers

  defstruct stack: []

  def init({screen, memory, registers, _, keyboard}, size) do
    stack = %Stack{
      stack: 0..(size - 1) |> Enum.map(fn _ -> 0x00 end)
    }

    {screen, memory, registers, stack, keyboard}
  end

  def stack_push({stack, registers}, value) do
    sp = Registers.lookup_register(:sp)

    if sp + 1 >= length(stack.stack),
      do: raise("Stack pointer out of bounds.")

    updated_stack_list = List.replace_at(stack.stack, sp, value)

    updated_stack = Map.put(stack, :stack, updated_stack_list)

    Registers.insert_register(:sp, sp + 1)
    {updated_stack, registers}
  end

  def stack_pop({stack, registers}) do
    sp = Registers.lookup_register(:sp)
    Registers.insert_register(:sp, sp - 1)

    {registers, Enum.at(stack.stack, Registers.lookup_register(:sp))}
  end
end
