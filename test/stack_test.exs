defmodule ExChip8.StackTest do
  use ExUnit.Case

  alias ExChip8.Stack
  alias ExChip8.State
  alias ExChip8.Registers

  describe "Empty stack" do
    test "init/1 initializes stack list" do
      size = 100
      state = Stack.init(%State{}, size)
      assert length(state.stack.stack) == size
    end
  end

  describe "Stack operations" do
    setup [:initialize_array]

    test "stack_push/2 increments stack pointer", %{state: state} do
      registers = Map.put(state.registers, :sp, 0xfe)
      state = Map.put(state, :registers, registers)

      assert state.registers.sp == 0xfe

      state = Stack.stack_push(state, 0x10)

      assert state.registers.sp == 0xff
    end

    test "stack_push/2 inserts value on top of stack", %{state: state} do
      registers = Map.put(state.registers, :sp, 0xfe)
      state = Map.put(state, :registers, registers)

      assert state.registers.sp == 0xfe

      state = Stack.stack_push(state, 0x10)

      assert Enum.at(state.stack.stack, 0xfe) == 0x10
    end

    test "stack_push/2 raises when out of bounds", %{state: state} do
      registers = Map.put(state.registers, :sp, 0xff)
      state = Map.put(state, :registers, registers)

      assert state.registers.sp == 0xff

      assert_raise RuntimeError, fn ->
        Stack.stack_push(state, 0x10)
      end
    end

    test "stack_pop/2 returns value from top of stack", %{state: state} do
      registers = Map.put(state.registers, :sp, 0xfe)
      state = Map.put(state, :registers, registers)
      updated_stack_list = List.replace_at(state.stack.stack, 0xfe - 1, 0x10)

      updated_stack = Map.put(state.stack, :stack, updated_stack_list)
      state = Map.put(state, :stack, updated_stack)

      assert state.registers.sp == 0xfe
      assert Enum.at(state.stack.stack, state.registers.sp - 1) == 0x10

      assert {_state, 0x10} = Stack.stack_pop(state)
    end

    test "stack_pop/2 decrements stack pointer", %{state: state} do
      registers = Map.put(state.registers, :sp, 0xfe)
      state = Map.put(state, :registers, registers)
      updated_stack_list = List.replace_at(state.stack.stack, 0xfe, 0x10)

      updated_stack = Map.put(state.stack, :stack, updated_stack_list)
      state = Map.put(state, :stack, updated_stack)

      assert state.registers.sp == 0xfe
      assert Enum.at(state.stack.stack, state.registers.sp) == 0x10

      {state, _} = Stack.stack_pop(state)

      assert state.registers.sp == 0xfd
    end
  end

  defp initialize_array(_) do
    state =
      %State{}
      |> Registers.init(16)
      |> Stack.init(256)

    %{state: state}
  end
end
