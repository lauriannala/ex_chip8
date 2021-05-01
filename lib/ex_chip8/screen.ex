defmodule ExChip8.Screen do
  alias ExChip8.Screen

  defstruct sleep_wait_period: 0,
            chip8_height: 0,
            chip8_width: 0,
            pixels: []

  alias ExChip8.State
  alias ExChip8.Keyboard
  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, EventManager, Event, Position}

  def init_screen() do
    Termbox.init()

    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())
  end

  def init_state(
    %State{} = state,
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
    case screen_is_set?(screen, x, y) do
      true -> "■"
      false -> " "
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
    } = screen,
    keyboard: %Keyboard{} = keyboard
  } = state) do

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

    draw_message('(Press <q> to quit)', chip8_height + 1)
    draw_message(state.message_box, chip8_height + 2)

    Termbox.present()

    mailbox = receive_messages(keyboard, sleep_wait_period)

    mailbox_update(state, mailbox)
  end

  def draw_message(message, offset) do
    Enum.with_index(message)
    |> Enum.map(fn {ch, x} ->
      :ok = Termbox.put_cell(%Cell{position: %Position{x: x, y: offset}, ch: ch})
    end)
  end

  def receive_messages(keyboard, sleep_wait_period) do
    receive do
      {:event, %Event{ch: ?q}} ->

        :ok = Termbox.shutdown()
        Process.exit(self(), :normal)

      {:event, %Event{ch: pressed_key}} ->

        index = Keyboard.keyboard_map(keyboard, pressed_key)
        if (index != false) do
          updated_keyboard = Keyboard.keyboard_down(keyboard, index)

          {:update_keyboard, updated_keyboard, pressed_key}
        else
          :unknown_key
        end
    after
      sleep_wait_period ->
        :ok
    end
  end

  def mailbox_update(state, {:update_keyboard, keyboard, key}) do
    Map.put(state, :keyboard, keyboard)
    |> Map.put(:message_box, 'Key pressed: ' ++ [key])
  end

  def mailbox_update(state, _) do
    Map.put(state, :message_box, '              ')
  end
end
