defmodule ExChip8.KeyboardTest do
  use ExChip8.StateCase

  alias ExChip8.{Screen, Keyboard}

  describe "Unitialized keyboard" do
    test "init/2 initializes keys" do
      size = 16

      {_, _, _, _, keyboard} = Keyboard.init({%Screen{}, nil, nil, nil, %Keyboard{}}, size)

      assert length(keyboard.keyboard |> Map.keys()) == size
      assert Enum.all?(keyboard.keyboard |> Map.values(), &(&1 == false)) == true
    end
  end

  describe "Keyboard operations" do
    setup [:initialize_keyboard]

    test "keyboard_set_map/2 sets keyboard map", %{state: state} do
      map = [?0, ?1, ?2]
      {_, _, _, _, keyboard} = Keyboard.keyboard_set_map(state, map)
      assert keyboard.keyboard_map == %{?0 => 0, ?1 => 1, ?2 => 2}
    end
  end

  describe "Keyboard operations with map" do
    setup [:initialize_keyboard_with_map]

    test "keyboard_map/2 maps given key", %{keyboard: keyboard} do
      assert Keyboard.keyboard_map(keyboard, ?0) == 0
      assert Keyboard.keyboard_map(keyboard, ?1) == 1
      assert Keyboard.keyboard_map(keyboard, ?2) == 2
    end

    test "keyboard_map/2 returns false if key is not found", %{keyboard: keyboard} do
      assert Keyboard.keyboard_map(keyboard, 16) == false
    end

    test "keyboard_down/2 sets key down at index", %{keyboard: keyboard} do
      keyboard = Keyboard.keyboard_down(keyboard, 0)

      assert true == Map.get(keyboard.keyboard, 0)

      keyboard = Keyboard.keyboard_down(keyboard, 1)

      assert true == Map.get(keyboard.keyboard, 1)
      assert false == Map.get(keyboard.keyboard, 2)
    end

    test "keyboard_down/2 sets key up at index", %{keyboard: keyboard} do
      keyboard =
        keyboard
        |> Keyboard.keyboard_down(0)
        |> Keyboard.keyboard_down(1)
        |> Keyboard.keyboard_down(2)

      keyboard = Keyboard.keyboard_up(keyboard, 0)

      assert false == Map.get(keyboard.keyboard, 0)

      keyboard = Keyboard.keyboard_up(keyboard, 1)

      assert false == Map.get(keyboard.keyboard, 1)
      assert true == Map.get(keyboard.keyboard, 2)
    end

    test "keyboard_is_down checks if key is pressed on given index", %{keyboard: keyboard} do
      keyboard = Keyboard.keyboard_down(keyboard, 1)

      assert Keyboard.keyboard_is_down(keyboard, 0) == false
      assert Keyboard.keyboard_is_down(keyboard, 1) == true
      assert Keyboard.keyboard_is_down(keyboard, 2) == false
    end
  end

  defp initialize_keyboard(_) do
    {_, _, _, _, keyboard} = state = Keyboard.init({%Screen{}, nil, nil, nil, %Keyboard{}}, 16)

    %{keyboard: keyboard, state: state}
  end

  defp initialize_keyboard_with_map(_) do
    {_, _, _, _, keyboard} =
      {%Screen{}, nil, nil, nil, %Keyboard{}}
      |> Keyboard.init(16)
      |> Keyboard.keyboard_set_map([?0, ?1, ?2])

    %{keyboard: keyboard}
  end
end
