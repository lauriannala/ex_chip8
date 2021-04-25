defmodule ExChip8.State do
  defstruct screen: %ExChip8.Screen{},
    memory: %ExChip8.Memory{},
    registers: %ExChip8.Registers{}
end
