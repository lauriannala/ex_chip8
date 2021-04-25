defmodule ExChip8.Screen do

  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, EventManager, Event, Position}

  def init(state) do
    Termbox.init()

    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())
    state
  end

  def draw(%{
    sleep_wait_period: sleep_wait_period,
    chip8_height: chip8_height,
    chip8_width: chip8_width
  }) do
    0..chip8_height
    |> Enum.map(fn y ->

      0..chip8_width
      |> Enum.map(&char/1)
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

  def char(_) do
    Enum.random(["■", " "])
  end
end