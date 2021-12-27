defmodule ExChip8.Registers do
  alias ExChip8.StateServer

  def init({screen, memory, registers, stack, keyboard}, v_size) do
    0..(v_size - 1)
    |> Enum.each(fn index ->
      insert_v_register(index, 0x0)
    end)

    insert_register(:i, 0x00)
    insert_register(:delay_timer, 0)
    insert_register(:sound_timer, 0)
    insert_register(:pc, 0x00)
    insert_register(:sp, 0x0)

    {screen, memory, registers, stack, keyboard}
  end

  def lookup_v_register(index) when is_integer(index) do
    [{^index, value}] = GenServer.call(StateServer, {:lookup_v_register, index})
    value
  end

  def insert_v_register(index, value) when is_integer(index) do
    GenServer.call(StateServer, {:insert_v_register, index, value})
  end

  def lookup_register(register) when is_atom(register) do
    [{^register, value}] = GenServer.call(StateServer, {:lookup_register, register})
    value
  end

  def insert_register(register, value) when is_atom(register) do
    GenServer.call(StateServer, {:insert_register, register, value})
  end
end
