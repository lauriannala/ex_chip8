defmodule ExChip8.Screen do
  alias ExChip8.Screen
  alias ExChip8.StateServer

  defstruct sleep_wait_period: 0,
            chip8_height: 0,
            chip8_width: 0,
            pixels: []

  alias ExChip8.Memory

  import Bitwise

  require Logger

  def get_screen() do
    GenServer.call(StateServer, {:get_screen})
  end

  def update(%Screen{} = screen) do
    GenServer.call(StateServer, {:update_screen, screen})
  end

  def init_state(
        sleep_wait_period: sleep_wait_period,
        chip8_height: chip8_height,
        chip8_width: chip8_width
      ) do
    screen = %Screen{
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

    screen
  end

  def screen_set(%Screen{} = screen, x, y) do
    %{^y => row} = screen.pixels

    updated_row = row |> Map.replace!(x, true)

    updated_pixels = screen.pixels |> Map.replace!(y, updated_row)

    Map.put(screen, :pixels, updated_pixels)
  end

  def screen_clear(
        %Screen{
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
  end

  def screen_unset(%Screen{} = screen, x, y) do
    %{^y => row} = screen.pixels

    updated_row = row |> Map.replace!(x, false)

    updated_pixels = screen.pixels |> Map.replace!(y, updated_row)

    Map.put(screen, :pixels, updated_pixels)
  end

  def screen_is_set?(%Screen{} = screen, x, y) do
    %{^y => row} = screen.pixels

    %{^x => col} = row

    col
  end

  def screen_draw_sprite(%Screen{} = screen, attrs) do
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

  def screen_draw_sprite_changeset(%Screen{} = screen, %{
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
