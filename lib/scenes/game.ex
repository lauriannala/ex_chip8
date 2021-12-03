defmodule ExChip8.Scenes.Game do
  use Scenic.Scene
  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives, only: [text: 3]

  @graph Graph.build(font: :roboto, font_size: 36)
  @tile_size 32

  def init(_, opts) do
    viewport = opts[:viewport]

    state = %{
      viewport: viewport,
      graph: @graph,
      opcode: 0x0000
    }

    graph =
      state.graph
      |> draw_opcode(state.opcode)

    {:ok, state, push: graph}
  end

  defp draw_opcode(graph, opcode) do
    hex_format = Integer.to_charlist(opcode, 16)

    graph
    |> text("Opcode: 0x#{hex_format}", fill: :white, translate: {@tile_size, @tile_size})
  end
end
