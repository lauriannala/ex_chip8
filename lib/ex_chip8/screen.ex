defmodule ExChip8.Screen do
  alias ExChip8.Screen

  defstruct sleep_wait_period: 0,
            chip8_height: 0,
            chip8_width: 0,
            pixels: []

  alias ExChip8.State
  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, EventManager, Event, Position}

  def init_screen() do
    Termbox.init()

    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())
  end

  def init_state(%State{} = state,
        sleep_wait_period: sleep_wait_period,
        chip8_height: chip8_height,
        chip8_width: chip8_width
      ) do
    screen = %Screen{
      sleep_wait_period: sleep_wait_period,
      chip8_height: chip8_height,
      chip8_width: chip8_width,
      pixels: 0..(chip8_height - 1) |> Enum.map(fn _ ->
        0..(chip8_width - 1) |> Enum.map(fn _ -> false end)
      end)
    }

    Map.put(state, :screen, screen)
  end

  def char(%Screen{} = screen, x, y) do
    set = screen_is_set?(screen, x, y)
    if set do
      "■"
    else
      " "
    end
  end

  def screen_set(%Screen{} = screen, x, y) do
    row = Enum.at(screen.pixels, y)
    updated_row = List.replace_at(row, x, true)

    updated_pixels = List.replace_at(screen.pixels, y, updated_row)

    Map.put(screen, :pixels, updated_pixels)
  end

  def screen_is_set?(%Screen{} = screen, x, y) do
    row = Enum.at(screen.pixels, y)
    if row == nil, do: raise "x: #{x} is out of bounds."

    col = Enum.at(row, x)
    if col == nil, do: raise "y: #{y} is out of bounds."

    col
  end

  def draw(%State{
        screen: %Screen{
          sleep_wait_period: sleep_wait_period,
          chip8_height: chip8_height,
          chip8_width: chip8_width
        } = screen
      }) do
    0..(chip8_height - 1)
    |> Enum.map(fn y ->
      0..(chip8_width - 1)
      |> Enum.map(fn x -> char(screen, x, y) end)
      |> Enum.join(" ")
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.map(fn {ch, x} ->
        :ok = Termbox.put_cell(%Cell{position: %Position{x: x, y: y}, ch: ch})
      end)
    end)

    Enum.with_index('(Press <q> to quit)')
    |> Enum.map(fn {ch, x} ->
      :ok = Termbox.put_cell(%Cell{position: %Position{x: x, y: chip8_height + 1}, ch: ch})
    end)

    Termbox.present()

    receive do
      {:event, %Event{ch: ?q}} ->
        :ok = Termbox.shutdown()
        Process.exit(self(), :normal)
    after
      sleep_wait_period ->
        :ok
    end
  end
end
