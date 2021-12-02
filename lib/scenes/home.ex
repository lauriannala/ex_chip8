defmodule ExChip8.Scenes.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.ViewPort

  import Scenic.Primitives

  require Logger

  @note """
    ExChip8
  """

  @text_size 24

  def init(_, opts) do
    {:ok, %ViewPort.Status{size: {width, height}}} = ViewPort.info(opts[:viewport])

    scenic_ver = Application.spec(:scenic, :vsn) |> to_string()
    glfw_ver = Application.spec(:scenic_driver_glfw, :vsn) |> to_string()

    graph =
      Graph.build(font: :roboto, font_size: @text_size)
      |> add_specs_to_graph([
        text_spec("scenic: v" <> scenic_ver, translate: {20, 40}),
        text_spec("glfw: v" <> glfw_ver, translate: {20, 40 + @text_size}),
        text_spec(@note, translate: {20, 150}),
        rect_spec({width, height})
      ])

    {:ok, graph, push: graph}
  end

  def handle_input(event, _context, state) do
    Logger.info("Received event: #{inspect(event)}")
    {:noreply, state}
  end
end
