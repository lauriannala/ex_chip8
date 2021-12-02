defmodule ExChip8.Screen do
  alias ExChip8.Screen

  defstruct sleep_wait_period: 0,
            chip8_height: 0,
            chip8_width: 0,
            pixels: []

  alias ExChip8.State
  alias ExChip8.Keyboard
  alias ExChip8.Memory

  import Bitwise

  require Logger

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
      pixels:
        0..(chip8_height - 1)
        |> Enum.map(fn _ ->
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
    end)
  end

  def screen_unset(%Screen{} = screen, x, y) do
    row = Enum.at(screen.pixels, y)
    updated_row = List.replace_at(row, x, false)

    updated_pixels = List.replace_at(screen.pixels, y, updated_row)

    Map.put(screen, :pixels, updated_pixels)
  end

  def screen_is_set?(%Screen{} = screen, x, y) do
    row = Enum.at(screen.pixels, y)
    if row == nil, do: raise("x: #{x} is out of bounds.")

    col = Enum.at(row, x)
    if col == nil, do: raise("y: #{y} is out of bounds.")

    col
  end

  def screen_draw_sprite(
        %{
          screen: %Screen{} = screen
        } = attrs
      ) do
    changeset = screen_draw_sprite_changeset(attrs)

    screen =
      changeset
      |> Enum.reduce(screen, fn c, updated_screen ->
        {:update, %{collision: _, pixel: pixel, x: x, y: y}} = c

        if pixel do
          screen_set(updated_screen, x, y)
        else
          screen_unset(updated_screen, x, y)
        end
      end)

    collision =
      changeset
      |> Enum.any?(fn {:update, %{collision: collision, pixel: _, x: _, y: _}} ->
        collision == true
      end)

    %{collision: collision, screen: screen}
  end

  def screen_draw_sprite_changeset(%{
        screen: %Screen{} = screen,
        x: x,
        y: y,
        memory: %Memory{} = memory,
        sprite_index: sprite_index,
        num: num
      }) do
    sprite_bytes =
      memory.memory
      |> Enum.drop(sprite_index)
      |> Enum.take(num)

    changeset =
      0..(num - 1)
      |> Enum.map(fn ly ->
        char = Enum.at(sprite_bytes, ly)

        y_target = rem(ly + y, screen.chip8_height)
        row = Enum.at(screen.pixels, y_target)

        0..(8 - 1)
        |> Enum.map(fn lx ->
          if (char &&& 0b10000000 >>> lx) == 0 do
            {:skip, %{}}
          else
            x_target = rem(lx + x, screen.chip8_width)
            pixel = Enum.at(row, x_target)

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

  def draw(
        %State{
          screen:
            %Screen{
              sleep_wait_period: sleep_wait_period,
              chip8_height: chip8_height,
              chip8_width: chip8_width
            } = screen,
          keyboard: %Keyboard{} = keyboard
        } = state,
        opcode
      ) do
    0..(chip8_height - 1)
    |> Enum.map(fn y ->
      0..(chip8_width - 1)
      |> Enum.map(fn x -> char(screen, x, y) end)
      |> Enum.join(" ")
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} ->
        # TODO: render char to x, y coordinates.
        Logger.info("Render: #{char}, x: #{x}, y: #{y}")
      end)
    end)

    _ = receive_messages(keyboard)

    Logger.info("Delay timer: #{state.registers.delay_timer}")

    Logger.info("Sound timer: #{state.registers.sound_timer}")

    Logger.info(state.filename)
    Logger.info("#{opcode}")
    Logger.info("Instruction: #{state.instruction}")

    state =
      state
      |> apply_delay()
      |> apply_sound()
  end

  def apply_delay(%State{} = state) do
    if state.registers.delay_timer == 0 do
      state
    else
      :timer.sleep(100)

      updated_registers =
        state.registers
        |> Map.update!(:delay_timer, fn t -> t - 1 end)

      Map.put(state, :registers, updated_registers)
    end
  end

  def apply_sound(%State{} = state) do
    if state.registers.sound_timer == 0 do
      state
    else
      updated_registers =
        state.registers
        |> Map.update!(:sound_timer, fn t -> t - 1 end)

      Map.put(state, :registers, updated_registers)
    end
  end

  def receive_messages(keyboard) do
    case keyboard do
      {:event, :quit} ->
        # TODO: close game
        Process.exit(self(), :normal)

      {:event, pressed_key} ->
        index = Keyboard.keyboard_map(keyboard, pressed_key)

        if index != false do
          updated_keyboard =
            Keyboard.keyboard_down(keyboard, index)
            |> Map.put(:pressed_key, pressed_key)

          {:update_keyboard, updated_keyboard}
        else
          :unknown_key
        end

      _ ->
        :ok
    end
  end
end
