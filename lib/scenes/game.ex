defmodule ExChip8.Scenes.Game do
  use Scenic.Scene
  alias Scenic.Graph
  alias ExChip8.{State, Screen, Keyboard}
  import Scenic.Primitives, only: [rectangle: 3, text: 3]
  import ExChip8.Screen

  @chip8_tile_size Application.get_env(:ex_chip8, :chip8_tile_size)
  @graph Graph.build(font: :roboto, font_size: @chip8_tile_size)

  @chip8_width Application.get_env(:ex_chip8, :chip8_width)
  @chip8_height Application.get_env(:ex_chip8, :chip8_height)
  @sleep_wait_period Application.get_env(:ex_chip8, :sleep_wait_period)

  @default_character_set Application.get_env(:ex_chip8, :chip8_default_character_set)
  @chip8_program_load_address Application.get_env(:ex_chip8, :chip8_program_load_address)

  def init(_, opts) do
    viewport = opts[:viewport]

    chip8 =
      %State{}
      # TODO: as parameter
      |> ExChip8.create_state("TETRIS")
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
      opcode: 0x0000,
      chip8: chip8
    }

    graph =
      state.graph
      |> draw_opcode(state.opcode)

    {:ok, state, push: graph}
  end

  def handle_info(:frame, %{frame_count: frame_count, chip8: %State{} = chip8} = state) do
    opcode = ExChip8.Memory.memory_get_short(chip8.memory, chip8.registers.pc)

    next_cycle =
      chip8
      |> Map.update!(:registers, fn registers ->
        registers
        |> Map.update!(:pc, fn counter -> counter + 2 end)
      end)
      |> ExChip8.Instructions.exec(opcode)

    updated_chip8 =
      case next_cycle do
        :wait_for_key_press ->
          chip8

        _ ->
          next_cycle
      end

    {graph, updated_chip8} = draw_chip8(state.graph, updated_chip8)

    graph = draw_opcode(graph, state.opcode)

    {:noreply, %{state | frame_count: frame_count + 1, opcode: opcode, chip8: updated_chip8},
     push: graph}
  end

  defp draw_chip8(
         graph,
         %State{
           screen:
             %Screen{
               sleep_wait_period: sleep_wait_period,
               chip8_height: chip8_height,
               chip8_width: chip8_width
             } = screen,
           keyboard: %Keyboard{} = keyboard
         } = state
       ) do
    graph =
      Enum.reduce(0..(chip8_height - 1), graph, fn y, tranform_y ->
        Enum.reduce(0..(chip8_width - 1), tranform_y, fn x, tranform_x ->
          case screen_is_set?(screen, x, y) do
            true -> draw_tile(tranform_x, x, y)
            false -> draw_tile(tranform_x, x, y, fill: :black)
          end
        end)
      end)

    {graph, state}
  end

  defp draw_tile(graph, x, y, opts \\ []) do
    tile_opts =
      Keyword.merge([fill: :white, translate: {x * @chip8_tile_size, y * @chip8_tile_size}], opts)

    graph |> rectangle({@chip8_tile_size, @chip8_tile_size}, tile_opts)
  end

  defp draw_opcode(graph, opcode) do
    hex_format = Integer.to_charlist(opcode, 16)

    graph
    |> text("Opcode: 0x#{hex_format}",
      fill: :white,
      translate: {@chip8_tile_size, @chip8_tile_size}
    )
  end
end
