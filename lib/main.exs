args = System.argv()

case args |> OptionParser.parse(switches: [], args: [:filename]) do
  {_, [filename], _} ->
    ExChip8.start(filename)

  _ ->
    raise ArgumentError, message: "Filename is missing."
end
