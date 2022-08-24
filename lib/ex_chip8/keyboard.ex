defmodule ExChip8.Keyboard do
  use ExChip8.State

  @moduledoc """
  Implements struct for persisting keyboard data and methods for manipulating keyboard state.
  """

  defstruct keyboard: [],
            keyboard_map: [],
            pressed_key: false

  @doc """
  Request keyboard from server.
  """
  @spec get_keyboard() :: %__MODULE__{}
  def get_keyboard() do
    GenServer.call(StateServer, {:get_keyboard})
  end

  @doc """
  Request server to update keyboard.
  """
  @spec update(keyboard :: %__MODULE__{}) :: %__MODULE__{}
  def update(%__MODULE__{} = keyboard) do
    GenServer.call(StateServer, {:update_keyboard, keyboard})
  end

  @doc """
  Initalize keyboard with provided size.
  """
  @spec init(k_size :: integer) :: %__MODULE__{}
  def init(k_size) do
    %__MODULE__{
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
  @spec keyboard_set_map(keyboard :: %__MODULE__{}, map :: list(String.t())) :: %__MODULE__{}
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
  @spec keyboard_map(keyboard :: %__MODULE__{}, char :: integer) :: false | integer
  def keyboard_map(%__MODULE__{} = keyboard, char) do
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
  @spec keyboard_down(keyboard :: %__MODULE__{}, index :: integer) :: %__MODULE__{}
  def keyboard_down(%__MODULE__{} = keyboard, index) do
    updated_keyboard_list = keyboard.keyboard |> Map.replace!(index, true)
    Map.put(keyboard, :keyboard, updated_keyboard_list)
  end

  @doc """
  Set specified index as up/not pressed/false.
  """
  @spec keyboard_up(keyboard :: %__MODULE__{}, index :: integer) :: %__MODULE__{}
  def keyboard_up(%__MODULE__{} = keyboard, index) do
    updated_keyboard_list = keyboard.keyboard |> Map.replace!(index, false)
    Map.put(keyboard, :keyboard, updated_keyboard_list)
  end

  @doc """
  Get pressed-status of specified index.
  """
  @spec keyboard_is_down(keyboard :: %__MODULE__{}, key :: integer) :: boolean
  def keyboard_is_down(%__MODULE__{} = keyboard, key) do
    keyboard.keyboard |> Map.get(key, false)
  end
end
