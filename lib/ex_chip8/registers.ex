defmodule ExChip8.Registers do
  alias ExChip8.StateServer

  @moduledoc """
  Implements methods for retrieving and manipulating register data from StateServer.
  """

  @doc """
  Initializes registers.

  V-register with specified size.
  I-register with default value of 0x00.
  Delay timer register with default value of 0.
  Sound timer register with default value of 0.
  Program counter register with default value of 0x00.
  Stack pointer register with default value of 0x0.
  """
  @spec init(v_size :: integer) :: :ok
  def init(v_size) do
    0..(v_size - 1)
    |> Enum.each(fn index ->
      insert_v_register(index, 0x0)
    end)

    insert_register(:i, 0x00)
    insert_register(:delay_timer, 0)
    insert_register(:sound_timer, 0)
    insert_register(:pc, 0x00)
    insert_register(:sp, 0x0)

    :ok
  end

  @doc """
  Request server to lookup v-register value from specified index.
  """
  @spec lookup_v_register(index :: integer) :: integer
  def lookup_v_register(index) when is_integer(index) do
    [{^index, value}] = GenServer.call(StateServer, {:lookup_v_register, index})
    value
  end

  @doc """
  Request server to insert value to v-register at specified index.
  """
  @spec insert_v_register(index :: integer, value :: integer) :: :ok
  def insert_v_register(index, value) when is_integer(index) do
    GenServer.call(StateServer, {:insert_v_register, index, value})

    :ok
  end

  @doc """
  Request server to lookup value from specified register.
  """
  @spec lookup_register(register :: atom) :: integer
  def lookup_register(register) when is_atom(register) do
    [{^register, value}] = GenServer.call(StateServer, {:lookup_register, register})
    value
  end

  @doc """
  Request server to insert value to specified register.
  """
  @spec insert_register(register :: atom, value :: integer) :: integer
  def insert_register(register, value) when is_atom(register) do
    GenServer.call(StateServer, {:insert_register, register, value})
  end

  @doc """
  Request server to apply delay timer updates.
  """
  @spec apply_delay() :: :ok
  def apply_delay() do
    delay_timer = lookup_register(:delay_timer)

    if delay_timer != 0 do
      insert_register(:delay_timer, delay_timer - 1)
    end

    :ok
  end

  @doc """
  Request server to apply sound timer updates.
  """
  @spec apply_sound() :: :ok
  def apply_sound() do
    sound_timer = lookup_register(:sound_timer)

    if sound_timer != 0 do
      insert_register(:sound_timer, sound_timer - 1)
    end

    :ok
  end
end
