defmodule ExChip8.Stack do
  alias ExChip8.State
  alias ExChip8.Stack

  defstruct stack: []

  def init(%State{} = state, size) do
    stack = %Stack{
      stack: 0..(size - 1) |> Enum.map(fn _ -> 0x00 end)
    }

    Map.put(state, :stack, stack)
  end

  def stack_push(%State{} = state, value) do
    if state.registers.sp + 1 >= length(state.stack.stack),
      do: raise("Stack pointer out of bounds.")

    updated_stack_list = List.replace_at(state.stack.stack, state.registers.sp, value)

    updated_stack = Map.put(state.stack, :stack, updated_stack_list)
    state = Map.put(state, :stack, updated_stack)

    registers = Map.update!(state.registers, :sp, fn stack_pointer -> stack_pointer + 1 end)
    Map.put(state, :registers, registers)
  end

  def stack_pop(%State{} = state) do
    registers = Map.update!(state.registers, :sp, fn stack_pointer -> stack_pointer - 1 end)
    state = Map.put(state, :registers, registers)

    {state, Enum.at(state.stack.stack, state.registers.sp)}
  end
end
