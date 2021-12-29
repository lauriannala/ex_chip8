defmodule ExChip8.Keyboard do
  alias ExChip8.Keyboard
  alias ExChip8.StateServer

  defstruct keyboard: [],
            keyboard_map: [],
            pressed_key: false

  def get_keyboard() do
    GenServer.call(StateServer, {:get_keyboard})
  end

  def update(%Keyboard{} = keyboard) do
    GenServer.call(StateServer, {:update_keyboard, keyboard})
  end

  def init(k_size) do
    keyboard = %Keyboard{
      keyboard:
        0..(k_size - 1)
        |> Enum.with_index()
        |> Enum.map(fn {index, _element} -> {index, false} end)
        |> Map.new()
    }

    keyboard
  end

  def keyboard_set_map(keyboard, map) do
    keyboard_map =
      map
      |> Enum.with_index()
      |> Enum.map(fn {index, element} -> {index, element} end)
      |> Map.new()

    Map.put(keyboard, :keyboard_map, keyboard_map)
  end

  def keyboard_map(%Keyboard{} = keyboard, char) do
    result =
      keyboard.keyboard_map
      |> Map.get(char, false)

    case result do
      false -> false
      index -> index
    end
  end

  def keyboard_down(%Keyboard{} = keyboard, index) do
    updated_keyboard_list = keyboard.keyboard |> Map.replace!(index, true)
    Map.put(keyboard, :keyboard, updated_keyboard_list)
  end

  def keyboard_up(%Keyboard{} = keyboard, index) do
    updated_keyboard_list = keyboard.keyboard |> Map.replace!(index, false)
    Map.put(keyboard, :keyboard, updated_keyboard_list)
  end

  def keyboard_is_down(%Keyboard{} = keyboard, key) do
    keyboard.keyboard |> Map.get(key, false)
  end
end
