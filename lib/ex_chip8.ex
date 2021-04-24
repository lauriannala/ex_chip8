defmodule ExChip8 do
  def main(args) do
    options = [switches: []]
    {opts,_,_} = OptionParser.parse(args, options)
    IO.inspect opts, label: "Command Line Arguments"
  end
end
