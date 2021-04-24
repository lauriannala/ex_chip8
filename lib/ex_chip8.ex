defmodule ExChip8 do
  def main(args) do
    options = [switches: []]
    {_opts, _, _} = OptionParser.parse(args, options)

    for n <- 1..100000, do: Screen.draw(n)

    :ok
  end
end
