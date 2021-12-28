defmodule ExChip8.StackTest do
  use ExChip8.StateCase

  alias ExChip8.{Screen, Registers, Stack, Keyboard}

  describe "Empty stack" do
    test "init/1 initializes stack list" do
      size = 100

      {_, _, _, _, _} = Stack.init({%Screen{}, nil, nil, nil, %Keyboard{}}, size)

      assert :ets.info(:stack)[:size] == size
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

      {_, _} = Stack.stack_push({stack, registers}, 0x10)

      assert 0x10 == Stack.lookup_stack(0xFE)
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
      Stack.insert_stack(0xFE - 1, 0x10)

      assert Registers.lookup_register(:sp) == 0xFE

      assert 0x10 == (Registers.lookup_register(:sp) - 1) |> Stack.lookup_stack()

      assert {_stack, 0x10} = Stack.stack_pop({stack, registers})
    end

    test "stack_pop/2 decrements stack pointer", %{state: {_, _, registers, stack, _}} do
      Registers.insert_register(:sp, 0xFE)
      Stack.insert_stack(0xFE, 0x10)

      assert Registers.lookup_register(:sp) == 0xFE
      assert 0x10 == Registers.lookup_register(:sp) |> Stack.lookup_stack()

      {_, _} = Stack.stack_pop({stack, registers})

      assert Registers.lookup_register(:sp) == 0xFD
    end
  end

  defp initialize_array(_) do
    state =
      {%Screen{}, nil, nil, nil, %Keyboard{}}
      |> Registers.init(16)
      |> Stack.init(256)

    %{state: state}
  end
end
