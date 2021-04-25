defmodule ExChip8.Registers do
  alias ExChip8.State

  defstruct v: [],
            i: 0x00,
            delay_timer: 0,
            sound_timer: 0,
            pc: 0x00,
            sp: 0x0

  def init(%State{} = state, v_size) do
    v = 0..(v_size - 1) |> Enum.map(fn _ -> 0x0 end)

    registers = Map.put(state.registers, :v, v)

    Map.put(state, :registers, registers)
  end
end
