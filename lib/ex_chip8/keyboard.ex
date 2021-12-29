defmodule ExChip8.Keyboard do
  alias ExChip8.Keyboard
  alias ExChip8.StateServer

  @moduledoc """
  Implements struct for persisting keyboard data and methods for manipulating keyboard state.
  """

  defstruct keyboard: [],
            keyboard_map: [],
            pressed_key: false

  @doc """
  Request keyboard from server.
  """
  @spec get_keyboard() :: %Keyboard{}
  def get_keyboard() do
    GenServer.call(StateServer, {:get_keyboard})
  end

  @doc """
  Request server to update keyboard.
  """
  @spec update(keyboard :: %Keyboard{}) :: %Keyboard{}
  def update(%Keyboard{} = keyboard) do
    GenServer.call(StateServer, {:update_keyboard, keyboard})
  end

  @doc """
  Initalize keyboard with provided size.
  """
  @spec init(k_size :: integer) :: %Keyboard{}
  def init(k_size) do
    %Keyboard{
      keyboard:
        0..(k_size - 1)
        |> Enum.with_index()
        |> Enum.map(fn {index, _element} -> {index, false} end)
        |> Map.new()
    }
  end

  @doc """
  Set keyboard with provided keyboard map.
  """
  @spec keyboard_set_map(keyboard :: %Keyboard{}, map :: list(String.t())) :: %Keyboard{}
  def keyboard_set_map(keyboard, map) do
    keyboard_map =
      map
      |> Enum.with_index()
      |> Enum.map(fn {index, element} -> {index, element} end)
      |> Map.new()

    Map.put(keyboard, :keyboard_map, keyboard_map)
  end

  @doc """
  Get keyboard mapping (index) for provided character.
  """
  @spec keyboard_map(keyboard :: %Keyboard{}, char :: integer) :: false | integer
  def keyboard_map(%Keyboard{} = keyboard, char) do
    result =
      keyboard.keyboard_map
      |> Map.get(char, false)

    case result do
      false -> false
      index -> index
    end
  end

  @doc """
  Set specified index as down/pressed/true.
  """
  @spec keyboard_down(keyboard :: %Keyboard{}, index :: integer) :: %Keyboard{}
  def keyboard_down(%Keyboard{} = keyboard, index) do
    updated_keyboard_list = keyboard.keyboard |> Map.replace!(index, true)
    Map.put(keyboard, :keyboard, updated_keyboard_list)
  end

  @doc """
  Set specified index as up/not pressed/false.
  """
  @spec keyboard_up(keyboard :: %Keyboard{}, index :: integer) :: %Keyboard{}
  def keyboard_up(%Keyboard{} = keyboard, index) do
    updated_keyboard_list = keyboard.keyboard |> Map.replace!(index, false)
    Map.put(keyboard, :keyboard, updated_keyboard_list)
  end

  @doc """
  Get pressed-status of specified index.
  """
  @spec keyboard_is_down(keyboard :: %Keyboard{}, key :: integer) :: boolean
  def keyboard_is_down(%Keyboard{} = keyboard, key) do
    keyboard.keyboard |> Map.get(key, false)
  end
end
