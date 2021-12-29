defmodule ExChip8.StackTest do
  use ExChip8.StateCase

  alias ExChip8.{Registers, Stack}

  describe "Empty stack" do
    test "init/1 initializes stack list" do
      size = 100

      Stack.init(size)

      assert :ets.info(:stack)[:size] == size
    end
  end

  describe "Stack operations" do
    setup [:initialize_array]

    test "stack_push/2 increments stack pointer", _ do
      Registers.insert_register(:sp, 0xFE)

      assert Registers.lookup_register(:sp) == 0xFE

      Stack.stack_push(0x10)

      assert Registers.lookup_register(:sp) == 0xFF
    end

    test "stack_push/2 inserts value on top of stack", _ do
      Registers.insert_register(:sp, 0xFE)

      assert Registers.lookup_register(:sp) == 0xFE

      Stack.stack_push(0x10)

      assert 0x10 == Stack.lookup_stack(0xFE)
    end

    test "stack_push/2 raises when out of bounds", _ do
      Registers.insert_register(:sp, 0xFF)

      assert Registers.lookup_register(:sp) == 0xFF

      assert_raise RuntimeError, fn ->
        Stack.stack_push(0x10)
      end
    end

    test "stack_pop/2 returns value from top of stack", _ do
      Registers.insert_register(:sp, 0xFE)
      Stack.insert_stack(0xFE - 1, 0x10)

      assert Registers.lookup_register(:sp) == 0xFE

      assert 0x10 == (Registers.lookup_register(:sp) - 1) |> Stack.lookup_stack()

      assert 0x10 = Stack.stack_pop()
    end

    test "stack_pop/2 decrements stack pointer", _ do
      Registers.insert_register(:sp, 0xFE)
      Stack.insert_stack(0xFE, 0x10)

      assert Registers.lookup_register(:sp) == 0xFE
      assert 0x10 == Registers.lookup_register(:sp) |> Stack.lookup_stack()

      Stack.stack_pop()

      assert Registers.lookup_register(:sp) == 0xFD
    end
  end

  defp initialize_array(_) do
    Registers.init(16)
    Stack.init(256)

    :ok
  end
end
