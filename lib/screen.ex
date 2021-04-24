defmodule Screen do
  @chip8_width 64
  @chip8_height 32

  @clear_height 100

  def draw(attrs) do

    # draw_command(&clear/0)
    # Process.sleep(10)
    draw_command(&random/0)
    Process.sleep(190)

    attrs
  end

  def draw_command(command) do
    {height, pixel} = command.()
    0..height
    |> Enum.map(fn _ ->
        get_line(pixel)
      end)
    |> IO.puts
  end

  def clear(), do: {@clear_height, fn -> " " end}

  def fill(), do: {@chip8_height, fn -> "■" end}

  def random(), do: {@chip8_height,
    fn ->
      Enum.random([" ", "■"])
    end
  }

  def get_line(pixel) do
    line = 0..@chip8_width |> Enum.map(fn _ -> pixel.() end)
    Enum.join(line ++ ["\n"], " ")
  end
end
