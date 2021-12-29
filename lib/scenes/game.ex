defmodule ExChip8.Scenes.Game do
  use Scenic.Scene
  alias Scenic.Graph
  alias ExChip8.{Screen, Registers, Keyboard}
  import Scenic.Primitives, only: [rectangle: 3]
  import ExChip8.Screen

  @chip8_tile_size Application.get_env(:ex_chip8, :chip8_tile_size)
  @graph Graph.build(font: :roboto, font_size: @chip8_tile_size)

  @chip8_width Application.get_env(:ex_chip8, :chip8_width)
  @chip8_height Application.get_env(:ex_chip8, :chip8_height)
  @sleep_wait_period Application.get_env(:ex_chip8, :sleep_wait_period)

  @default_character_set Application.get_env(:ex_chip8, :chip8_default_character_set)
  @chip8_program_load_address Application.get_env(:ex_chip8, :chip8_program_load_address)

  @chip8_filename Application.get_env(:ex_chip8, :filename)

  require Logger

  @impl true
  def init(_, opts) do
    viewport = opts[:viewport]

    ExChip8.create_state(@chip8_filename)
    |> ExChip8.init(@default_character_set)
    |> ExChip8.read_file_to_memory(@chip8_program_load_address)

    {:ok, timer} = :timer.send_interval(@sleep_wait_period, :frame)

    state = %{
      viewport: viewport,
      tile_width: trunc(@chip8_width / @chip8_tile_size),
      tile_height: trunc(@chip8_height / @chip8_tile_size),
      graph: @graph,
      frame_count: 1,
      frame_timer: timer,
      opcode: 0x0000
    }

    {:ok, state, push: state.graph}
  end

  @impl true
  def handle_info(
        :frame,
        %{frame_count: frame_count} = state
      ) do
    opcode = Registers.lookup_register(:pc) |> ExChip8.Memory.memory_get_short()

    pc = Registers.lookup_register(:pc)
    Registers.insert_register(:pc, pc + 2)

    ExChip8.Instructions.exec(opcode)

    graph =
      state.graph
      |> draw_chip8()

    apply_delay()
    apply_sound()

    {:noreply, %{state | frame_count: frame_count + 1, opcode: opcode}, push: graph}
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

  defp draw_chip8(graph) do
    %Screen{
      chip8_height: chip8_height,
      chip8_width: chip8_width
    } = screen = Screen.get_screen()

    changes =
      0..(chip8_height - 1)
      |> Enum.map(fn y ->
        0..(chip8_width - 1)
        |> Enum.map(fn x ->
          {x, y, screen_is_set?(screen, x, y)}
        end)
      end)
      |> List.flatten()
      |> Enum.filter(fn {_, _, is_set} -> is_set == true end)

    Enum.reduce(changes, graph, fn {x, y, _}, acc ->
      draw_tile(acc, x, y)
    end)
  end

  defp draw_tile(graph, x, y, opts \\ []) do
    tile_opts =
      Keyword.merge([fill: :white, translate: {x * @chip8_tile_size, y * @chip8_tile_size}], opts)

    graph |> rectangle({@chip8_tile_size, @chip8_tile_size}, tile_opts)
  end
end
