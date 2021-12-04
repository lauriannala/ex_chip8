defmodule ExChip8.Stack do
  alias ExChip8.Stack

  defstruct stack: []

  def init({screen, memory, registers, _, keyboard}, size) do
    stack = %Stack{
      stack: 0..(size - 1) |> Enum.map(fn _ -> 0x00 end)
    }

    {screen, memory, registers, stack, keyboard}
  end

  def stack_push({stack, registers}, value) do
    if registers.sp + 1 >= length(stack.stack),
      do: raise("Stack pointer out of bounds.")

    updated_stack_list = List.replace_at(stack.stack, registers.sp, value)

    updated_stack = Map.put(stack, :stack, updated_stack_list)

    registers = Map.update!(registers, :sp, fn stack_pointer -> stack_pointer + 1 end)
    {updated_stack, registers}
  end

  def stack_pop({stack, registers}) do
    registers = Map.update!(registers, :sp, fn stack_pointer -> stack_pointer - 1 end)

    {registers, Enum.at(stack.stack, registers.sp)}
  end
end
