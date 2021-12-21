defmodule ExChip8.Registers do
  defstruct v: [],
            i: 0x00,
            delay_timer: 0,
            sound_timer: 0,
            pc: 0x00,
            sp: 0x0

  def init({screen, memory, registers, stack, keyboard}, v_size) do
    v =
      0..(v_size - 1)
      |> Enum.each(fn index ->
        ExChip8.StateServer.insert_v_register(index, 0x0)
      end)

    registers = Map.put(registers, :v, v)
    v = 0..(v_size - 1) |> Enum.map(fn _ -> 0x0 end)

    registers = Map.put(registers, :v, v)

    {screen, memory, registers, stack, keyboard}
  end
end
