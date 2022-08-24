defmodule ExChip8.Screen do
  use ExChip8.State

  @moduledoc """
  Implements struct for persisting screen data and methods for manipulating screen state.
  """

  defstruct sleep_wait_period: 0,
            chip8_height: 0,
            chip8_width: 0,
            pixels: []

  alias ExChip8.Memory

  import Bitwise

  require Logger

  @doc """
  Request screen from server.
  """
  @spec get_screen() :: %__MODULE__{}
  def get_screen() do
    GenServer.call(StateServer, {:get_screen})
  end

  @doc """
  Request server to update screen.
  """
  @spec update(screen :: %__MODULE__{}) :: %__MODULE__{}
  def update(%__MODULE__{} = screen) do
    GenServer.call(StateServer, {:update_screen, screen})
  end

  @doc """
  Initialize screen with provided configuration.

  Pixels are mapped as rows which contain columns.
  """
  @spec init_state(sleep_wait_period: integer, chip8_height: integer, chip8_width: integer) ::
          %__MODULE__{}
  def init_state(
        sleep_wait_period: sleep_wait_period,
        chip8_height: chip8_height,
        chip8_width: chip8_width
      ) do
    %__MODULE__{
      sleep_wait_period: sleep_wait_period,
      chip8_height: chip8_height,
      chip8_width: chip8_width,
      pixels:
        0..(chip8_height - 1)
        |> Enum.with_index()
        |> Enum.map(fn {index, _element} ->
          cols =
            0..(chip8_width - 1)
            |> Enum.with_index()
            |> Enum.map(fn {index, _element} -> {index, false} end)
            |> Map.new()

          {index, cols}
        end)
        |> Map.new()
    }
  end

  @doc """
  Set screen pixel as on/true at specified location.
  """
  @spec screen_set(screen :: %__MODULE__{}, x :: integer, y :: integer) :: %__MODULE__{}
  def screen_set(%__MODULE__{} = screen, x, y) do
    %{^y => row} = screen.pixels

    updated_row = row |> Map.replace!(x, true)

    updated_pixels = screen.pixels |> Map.replace!(y, updated_row)

    Map.put(screen, :pixels, updated_pixels)
  end

  @doc """
  Clear all pixels from screen.

  All pixels will be set as off/false.
  """
  @spec screen_clear(screen :: %__MODULE__{}) :: :ok
  def screen_clear(
        %__MODULE__{
          chip8_height: chip8_height,
          chip8_width: chip8_width
        } = screen
      ) do
    changeset =
      0..(chip8_height - 1)
      |> Enum.map(fn y ->
        0..(chip8_width - 1)
        |> Enum.map(fn x -> {x, y} end)
      end)
      |> List.flatten()

    changeset
    |> Enum.reduce(screen, fn {x, y}, updated_screen ->
      screen_unset(updated_screen, x, y)
      |> update()
    end)

    :ok
  end

  @doc """
  Set screen pixel as off/false at specified location.
  """
  @spec screen_unset(screen :: %__MODULE__{}, x :: integer, y :: integer) :: %__MODULE__{}
  def screen_unset(%__MODULE__{} = screen, x, y) do
    %{^y => row} = screen.pixels

    updated_row = row |> Map.replace!(x, false)

    updated_pixels = screen.pixels |> Map.replace!(y, updated_row)

    Map.put(screen, :pixels, updated_pixels)
  end

  @doc """
  Check if pixel is set as on/true on screen.
  """
  @spec screen_is_set?(screen :: %__MODULE__{}, x :: integer, y :: integer) :: boolean
  def screen_is_set?(%__MODULE__{} = screen, x, y) do
    %{^y => row} = screen.pixels

    %{^x => col} = row

    col
  end

  @type draw_attrs :: %{x: integer, y: integer, sprite_index: integer, num: integer}
  @doc """
  Draw sprite with specified index to screen at specified location.
  """
  @spec screen_draw_sprite(screen :: %__MODULE__{}, attrs :: draw_attrs) :: %{collision: boolean}
  def screen_draw_sprite(%__MODULE__{} = screen, attrs) do
    changeset = screen_draw_sprite_changeset(screen, attrs)

    changeset
    |> Enum.reduce(screen, fn c, updated_screen ->
      {:update, %{collision: _, pixel: pixel, x: x, y: y}} = c

      if pixel do
        screen_set(updated_screen, x, y)
        |> update()
      else
        screen_unset(updated_screen, x, y)
        |> update()
      end
    end)

    collision =
      changeset
      |> Enum.any?(fn {:update, %{collision: collision, pixel: _, x: _, y: _}} ->
        collision == true
      end)

    %{collision: collision}
  end

  @type draw_changeset ::
          {:skip, %{}} | {:update, %{x: integer, y: integer, collision: boolean, pixel: boolean}}
  @doc """
  Create changeset for drawing a sprite at specified location.
  """
  @spec screen_draw_sprite_changeset(screen :: %__MODULE__{}, attrs :: draw_attrs) ::
          list(draw_changeset)
  def screen_draw_sprite_changeset(%__MODULE__{} = screen, %{
        x: x,
        y: y,
        sprite_index: sprite_index,
        num: num
      }) do
    sprite_bytes =
      Memory.memory_all_values()
      |> Enum.drop(sprite_index)
      |> Enum.take(num)

    changeset =
      0..(num - 1)
      |> Enum.map(fn ly ->
        char = Enum.at(sprite_bytes, ly)

        y_target = rem(ly + y, screen.chip8_height)
        %{^y_target => row} = screen.pixels

        0..(8 - 1)
        |> Enum.map(fn lx ->
          if (char &&& 0b10000000 >>> lx) == 0 do
            {:skip, %{}}
          else
            x_target = rem(lx + x, screen.chip8_width)

            %{^x_target => pixel} = row

            {:update,
             %{
               x: x_target,
               y: y_target,
               # Pixel was previously set as true.
               collision: pixel,
               # Basically XOR from previous state.
               pixel: !pixel
             }}
          end
        end)
      end)

    changeset
    |> List.flatten()
    |> Enum.filter(fn {status, _} -> status == :update end)
  end
end
