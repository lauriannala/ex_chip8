defmodule ExChip8.Keyboard do
  alias ExChip8.Keyboard
  alias ExChip8.State

  defstruct keyboard: [],
            keyboard_map: [],
            pressed_key: false

  def init(%State{} = state, k_size) do
    keyboard = %Keyboard{
      keyboard: 0..(k_size - 1) |> Enum.map(fn _ -> false end)
    }

    Map.put(state, :keyboard, keyboard)
  end

  def keyboard_set_map(%State{} = state, map) do
    updated_keyboard = Map.put(state.keyboard, :keyboard_map, map)
    Map.put(state, :keyboard, updated_keyboard)
  end

  def keyboard_map(%Keyboard{} = keyboard, char) do
    result = keyboard.keyboard_map
      |> Enum.with_index
      |> Enum.find(false, fn {map_value, _} -> map_value == char end)

    case result do
      {_, index} -> index
      false -> false
    end
  end

  def keyboard_down(%Keyboard{} = keyboard, index) do
    updated_keyboard_list = List.replace_at(keyboard.keyboard, index, true)
    Map.put(keyboard, :keyboard, updated_keyboard_list)
  end

  def keyboard_up(%Keyboard{} = keyboard, index) do
    updated_keyboard_list = List.replace_at(keyboard.keyboard, index, false)
    Map.put(keyboard, :keyboard, updated_keyboard_list)
  end

  def keyboard_is_down(%Keyboard{} = keyboard, key) do
    Enum.at(keyboard.keyboard, key, false)
  end
end
