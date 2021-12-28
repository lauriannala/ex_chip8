defmodule ExChip8.StackTest do
  use ExChip8.StateCase

  alias ExChip8.{Screen, Registers, Stack, Keyboard}

  describe "Empty stack" do
    test "init/1 initializes stack list" do
      size = 100

      {_, _, _, stack, _} = Stack.init({%Screen{}, nil, nil, %Stack{}, %Keyboard{}}, size)

      assert length(stack.stack) == size
    end
  end

  describe "Stack operations" do
    setup [:initialize_array]

    test "stack_push/2 increments stack pointer", %{state: {_, _, registers, stack, _}} do
      Registers.insert_register(:sp, 0xFE)

      assert Registers.lookup_register(:sp) == 0xFE

      {_, _} = Stack.stack_push({stack, registers}, 0x10)

      assert Registers.lookup_register(:sp) == 0xFF
    end

    test "stack_push/2 inserts value on top of stack", %{state: {_, _, registers, stack, _}} do
      Registers.insert_register(:sp, 0xFE)

      assert Registers.lookup_register(:sp) == 0xFE

      {stack, _} = Stack.stack_push({stack, registers}, 0x10)

      assert Enum.at(stack.stack, 0xFE) == 0x10
    end

    test "stack_push/2 raises when out of bounds", %{state: {_, _, registers, stack, _}} do
      Registers.insert_register(:sp, 0xFF)

      assert Registers.lookup_register(:sp) == 0xFF

      assert_raise RuntimeError, fn ->
        Stack.stack_push({stack, registers}, 0x10)
      end
    end

    test "stack_pop/2 returns value from top of stack", %{state: {_, _, registers, stack, _}} do
      Registers.insert_register(:sp, 0xFE)
      updated_stack_list = List.replace_at(stack.stack, 0xFE - 1, 0x10)

      updated_stack = Map.put(stack, :stack, updated_stack_list)

      assert Registers.lookup_register(:sp) == 0xFE
      assert Enum.at(updated_stack.stack, Registers.lookup_register(:sp) - 1) == 0x10

      assert {_stack, 0x10} = Stack.stack_pop({updated_stack, registers})
    end

    test "stack_pop/2 decrements stack pointer", %{state: {_, _, registers, stack, _}} do
      Registers.insert_register(:sp, 0xFE)
      updated_stack_list = List.replace_at(stack.stack, 0xFE, 0x10)

      updated_stack = Map.put(stack, :stack, updated_stack_list)

      assert Registers.lookup_register(:sp) == 0xFE
      assert Enum.at(updated_stack.stack, Registers.lookup_register(:sp)) == 0x10

      {_, _} = Stack.stack_pop({updated_stack, registers})

      assert Registers.lookup_register(:sp) == 0xFD
    end
  end

  defp initialize_array(_) do
    state =
      {%Screen{}, nil, nil, %Stack{}, %Keyboard{}}
      |> Registers.init(16)
      |> Stack.init(256)

    %{state: state}
  end
end
