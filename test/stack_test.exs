defmodule ExChip8.StackTest do
  use ExUnit.Case

  alias ExChip8.{Screen, Memory, Registers, Stack, Keyboard}

  describe "Empty stack" do
    test "init/1 initializes stack list" do
      size = 100

      {_, _, _, stack, _} =
        Stack.init({%Screen{}, %Memory{}, %Registers{}, %Stack{}, %Keyboard{}}, size)

      assert length(stack.stack) == size
    end
  end

  describe "Stack operations" do
    setup [:initialize_array]

    test "stack_push/2 increments stack pointer", %{state: {_, _, registers, stack, _}} do
      registers = Map.put(registers, :sp, 0xFE)

      assert registers.sp == 0xFE

      {_, registers} = Stack.stack_push({stack, registers}, 0x10)

      assert registers.sp == 0xFF
    end

    test "stack_push/2 inserts value on top of stack", %{state: {_, _, registers, stack, _}} do
      registers = Map.put(registers, :sp, 0xFE)

      assert registers.sp == 0xFE

      {stack, _} = Stack.stack_push({stack, registers}, 0x10)

      assert Enum.at(stack.stack, 0xFE) == 0x10
    end

    test "stack_push/2 raises when out of bounds", %{state: {_, _, registers, stack, _}} do
      registers = Map.put(registers, :sp, 0xFF)

      assert registers.sp == 0xFF

      assert_raise RuntimeError, fn ->
        Stack.stack_push({stack, registers}, 0x10)
      end
    end

    test "stack_pop/2 returns value from top of stack", %{state: {_, _, registers, stack, _}} do
      registers = Map.put(registers, :sp, 0xFE)
      updated_stack_list = List.replace_at(stack.stack, 0xFE - 1, 0x10)

      updated_stack = Map.put(stack, :stack, updated_stack_list)

      assert registers.sp == 0xFE
      assert Enum.at(updated_stack.stack, registers.sp - 1) == 0x10

      assert {_stack, 0x10} = Stack.stack_pop({updated_stack, registers})
    end

    test "stack_pop/2 decrements stack pointer", %{state: {_, _, registers, stack, _}} do
      registers = Map.put(registers, :sp, 0xFE)
      updated_stack_list = List.replace_at(stack.stack, 0xFE, 0x10)

      updated_stack = Map.put(stack, :stack, updated_stack_list)

      assert registers.sp == 0xFE
      assert Enum.at(updated_stack.stack, registers.sp) == 0x10

      {registers, _} = Stack.stack_pop({updated_stack, registers})

      assert registers.sp == 0xFD
    end
  end

  defp initialize_array(_) do
    state =
      {%Screen{}, %Memory{}, %Registers{}, %Stack{}, %Keyboard{}}
      |> Registers.init(16)
      |> Stack.init(256)

    %{state: state}
  end
end
