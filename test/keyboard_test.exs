defmodule ExChip8.KeyboardTest do
  use ExChip8.StateCase

  alias ExChip8.Keyboard

  describe "Unitialized keyboard" do
    test "init/2 initializes keys" do
      size = 16

      keyboard = Keyboard.init(size)

      assert length(keyboard.keyboard |> Map.keys()) == size
      assert Enum.all?(keyboard.keyboard |> Map.values(), &(&1 == false)) == true
    end
  end

  describe "Keyboard operations" do
    setup [:initialize_keyboard]

    test "keyboard_set_map/2 sets keyboard map", _ do
      map = [?0, ?1, ?2]
      keyboard = Keyboard.get_keyboard() |> Keyboard.keyboard_set_map(map)
      assert keyboard.keyboard_map == %{?0 => 0, ?1 => 1, ?2 => 2}
    end
  end

  describe "Keyboard operations with map" do
    setup [:initialize_keyboard_with_map]

    test "keyboard_map/2 maps given key", _ do
      assert Keyboard.keyboard_map(?0) == 0
      assert Keyboard.keyboard_map(?1) == 1
      assert Keyboard.keyboard_map(?2) == 2
    end

    test "keyboard_map/2 returns false if key is not found", _ do
      assert Keyboard.keyboard_map(16) == false
    end

    test "keyboard_down/2 sets key down at index", _ do
      keyboard = Keyboard.keyboard_down(0)

      assert true == Map.get(keyboard.keyboard, 0)

      keyboard = Keyboard.keyboard_down(1)

      assert true == Map.get(keyboard.keyboard, 1)
      assert false == Map.get(keyboard.keyboard, 2)
    end

    test "keyboard_down/2 sets key up at index", _ do
      Keyboard.keyboard_down(0) |> Keyboard.update()
      Keyboard.keyboard_down(1) |> Keyboard.update()
      Keyboard.keyboard_down(2) |> Keyboard.update()

      Keyboard.keyboard_up(0) |> Keyboard.update()

      keyboard = Keyboard.get_keyboard()

      assert false == Map.get(keyboard.keyboard, 0)

      Keyboard.keyboard_up(1) |> Keyboard.update()

      keyboard = Keyboard.get_keyboard()

      assert false == Map.get(keyboard.keyboard, 1)
      assert true == Map.get(keyboard.keyboard, 2)
    end

    test "keyboard_is_down checks if key is pressed on given index", _ do
      Keyboard.keyboard_down(1)
      |> Keyboard.update()

      assert false == Keyboard.keyboard_is_down(0)
      assert true == Keyboard.keyboard_is_down(1)
      assert false == Keyboard.keyboard_is_down(2)
    end
  end

  defp initialize_keyboard(_) do
    Keyboard.init(16)
    |> Keyboard.update()

    %{keyboard: Keyboard.get_keyboard()}
  end

  defp initialize_keyboard_with_map(_) do
    Keyboard.init(16)
    |> Keyboard.keyboard_set_map([?0, ?1, ?2])
    |> Keyboard.update()

    %{keyboard: Keyboard.get_keyboard()}
  end
end
