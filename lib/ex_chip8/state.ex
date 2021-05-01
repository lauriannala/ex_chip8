defmodule ExChip8.State do
  defstruct screen: %ExChip8.Screen{},
            memory: %ExChip8.Memory{},
            registers: %ExChip8.Registers{},
            stack: %ExChip8.Stack{},
            keyboard: %ExChip8.Keyboard{},
            message_box: ''
end
