defmodule Screen do
  @chip8_width 64
  @chip8_height 32

  @clear_height 10000

  def draw(attrs) do

    draw_command(&clear/0)
    Process.sleep(200)
    draw_command(&fill/0)
    Process.sleep(400)

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

  def clear(), do: {@clear_height, " "}

  def fill(), do: {@chip8_height, "■"}

  def get_line(pixel) do
    line = 0..@chip8_width |> Enum.map(fn _ -> pixel end)
    Enum.join(line ++ ["\n"], " ")
  end
end
