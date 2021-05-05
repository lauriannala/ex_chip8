
args = System.argv()

{_, [filename], _} =
  args
  |> OptionParser.parse(switches: [], args: [:filename])

ExChip8.start(filename)
