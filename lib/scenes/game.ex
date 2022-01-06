defmodule ExChip8.Scenes.Game do
  use Scenic.Scene
  alias Scenic.Graph
  alias ExChip8.{Screen, Registers, Keyboard}
  import Scenic.Primitives
  import Scenic.Components
  import ExChip8.Registers
  import ExChip8.Screen

  @chip8_tile_size Application.get_env(:ex_chip8, :chip8_tile_size)
  @font_size Application.get_env(:ex_chip8, :font_size)

  @chip8_width Application.get_env(:ex_chip8, :chip8_width)
  @chip8_height Application.get_env(:ex_chip8, :chip8_height)

  @graph Graph.build(font: :roboto, font_size: @font_size)
         |> button("Pause",
           id: :pause_button,
           translate: {trunc(@chip8_width * @chip8_tile_size), 35 + @font_size}
         )

  @init_screen Scenic.Utilities.Texture.build!(
                 :rgb,
                 @chip8_width * @chip8_tile_size,
                 @chip8_height * @chip8_tile_size
               )

  @sleep_wait_period Application.get_env(:ex_chip8, :sleep_wait_period)

  @default_character_set Application.get_env(:ex_chip8, :chip8_default_character_set)
  @chip8_program_load_address Application.get_env(:ex_chip8, :chip8_program_load_address)

  @chip8_filename Application.get_env(:ex_chip8, :filename)

  require Logger

  @impl true
  def init(_, opts) do
    viewport = opts[:viewport]

    screen = @init_screen
    Scenic.Cache.Dynamic.Texture.put("screen", screen)

    ExChip8.create_state(@chip8_filename)
    |> ExChip8.init_character_set(@default_character_set)
    |> ExChip8.read_file_to_memory(@chip8_program_load_address)

    {:ok, timer} = :timer.send_interval(@sleep_wait_period, :frame)

    graph =
      @graph
      |> rect({@chip8_width * @chip8_tile_size, @chip8_height * @chip8_tile_size},
        fill: {:dynamic, "screen"},
        translate: {0, 0},
        id: :chip8
      )

    state = %{
      viewport: viewport,
      tile_width: trunc(@chip8_width / @chip8_tile_size),
      tile_height: trunc(@chip8_height / @chip8_tile_size),
      graph: graph,
      frame_count: 1,
      frame_timer: timer,
      opcode: 0x0000,
      paused: false,
      screen: screen
    }

    {:ok, state, push: state.graph}
  end

  @impl true
  def handle_info(
        :frame,
        %{frame_count: frame_count, paused: paused, screen: screen} = state
        # ) when rem(frame_count, 10) == 0 do
      ) do
    opcode = Registers.lookup_register(:pc) |> ExChip8.Memory.memory_get_short()

    if not paused do
      pc = Registers.lookup_register(:pc)
      Registers.insert_register(:pc, pc + 2)

      executed = ExChip8.Instructions.exec(opcode)

      if executed == :wait_for_key_press do
        # Rewind program counter if waiting for key press.
        Registers.insert_register(:pc, pc)
      end
    end

    screen = draw_chip8(screen)
    Scenic.Cache.Dynamic.Texture.put("screen", screen)

    graph =
      state.graph
      |> add_specs_to_graph([
        text_spec("Current opcode:",
          translate: {trunc(@chip8_width * @chip8_tile_size), 30}
        ),
        text_spec(Integer.to_charlist(opcode, 16) |> to_string(),
          translate: {trunc(@chip8_width * @chip8_tile_size), 30 + @font_size}
        )
      ])

    if not paused do
      apply_delay()
      apply_sound()
    end

    {:noreply, %{state | frame_count: frame_count + 1, opcode: opcode, screen: screen},
     push: graph}
  end

  @impl true
  def handle_info(
        :frame,
        %{frame_count: frame_count} = state
      ) do
    {:noreply, %{state | frame_count: frame_count + 1}}
  end

  @impl true
  def filter_event({:click, :pause_button}, _, state) do
    {:noreply, %{state | paused: not state.paused}}
  end

  @impl true
  def handle_input(
        {:key, {pressed_key, :press, _}},
        _context,
        state
      ) do
    index = Keyboard.keyboard_map(Keyboard.get_keyboard(), pressed_key)

    case index do
      false ->
        {:noreply, state}

      _ ->
        Keyboard.get_keyboard()
        |> Keyboard.keyboard_down(index)
        |> Map.put(:pressed_key, pressed_key)
        |> Keyboard.update()

        {:noreply, state}
    end
  end

  @impl true
  def handle_input(
        {:key, {pressed_key, :release, _}},
        _context,
        state
      ) do
    index = Keyboard.keyboard_map(Keyboard.get_keyboard(), pressed_key)

    case index do
      false ->
        {:noreply, state}

      _ ->
        Keyboard.get_keyboard()
        |> Keyboard.keyboard_up(index)
        |> Map.put(:pressed_key, pressed_key)
        |> Keyboard.update()

        {:noreply, state}
    end
  end

  @impl true
  def handle_input(_, _, state), do: {:noreply, state}

  defp draw_chip8(screen) do
    %Screen{
      chip8_height: chip8_height,
      chip8_width: chip8_width
    } = chip8_screen = Screen.get_screen()

    changes =
      0..(chip8_height - 1)
      |> Enum.map(fn y ->
        0..(chip8_width - 1)
        |> Enum.map(fn x ->
          {x, y, screen_is_set?(chip8_screen, x, y)}
        end)
      end)
      |> List.flatten()
      |> Enum.filter(fn {_, _, is_set} -> is_set == true end)

    Enum.reduce(changes, screen, fn {x, y, _}, acc ->
      Enum.reduce(0..@chip8_tile_size, acc, fn x_offset, acc ->
        Enum.reduce(0..@chip8_tile_size, acc, fn y_offset, acc ->
          x_coord = x * @chip8_tile_size + x_offset
          y_coord = y * @chip8_tile_size + y_offset
          draw_tile(acc, x_coord, y_coord)
        end)
      end)
    end)
  end

  defp draw_tile(screen, x, y) do
    # tile_opts =
    #   Keyword.merge([fill: :white, translate: {x * @chip8_tile_size, y * @chip8_tile_size}], opts)

    # graph |> rectangle({@chip8_tile_size, @chip8_tile_size}, tile_opts)
    Scenic.Utilities.Texture.put!(screen, x, y, :white)
  end
end
