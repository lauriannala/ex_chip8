defmodule ExChip8 do
  @chip8_memory_size Application.compile_env!(:ex_chip8, :chip8_memory_size)
  @chip8_total_data_registers Application.compile_env!(:ex_chip8, :chip8_total_data_registers)
  @chip8_total_stack_depth Application.compile_env!(:ex_chip8, :chip8_total_stack_depth)

  alias ExChip8.Registers
  alias ExChip8.Memory

  @doc """
  Creates state and returns filename as charlist.

  Calls initialization for memory, registers and stack according to environment config.
  """
  @spec create_state(filename :: String.t()) :: charlist
  def create_state(filename) do
    ExChip8.Memory.init(@chip8_memory_size)
    ExChip8.Registers.init(@chip8_total_data_registers)
    ExChip8.Stack.init(@chip8_total_stack_depth)

    String.to_charlist(filename)
  end

  @doc """
  Initializes character set to memory, returns filename.
  """
  @spec init_character_set(charlist, list(integer)) :: charlist
  def init_character_set(filename, character_set) do
    values = Memory.memory_all_values()

    sliced =
      Enum.slice(
        values,
        -(length(values) - length(character_set)),
        length(values)
      )

    memory_with_character_set = [character_set | sliced] |> List.flatten()

    Memory.initialize_memory(memory_with_character_set)

    filename
  end

  @doc """
  Read file binary contents to memory and set program counter to specified load address.
  """
  @spec read_file_to_memory(charlist, load_address :: integer) :: :ok
  def read_file_to_memory(
        filename,
        load_address
      ) do
    game_binary = File.read!(filename)
    game_bytes = :binary.bin_to_list(game_binary)

    game_bytes
    |> Enum.with_index()
    |> Enum.each(fn {byte, byte_index} ->
      index = byte_index + load_address
      ExChip8.Memory.insert_memory(index, byte)
    end)

    Registers.insert_register(:pc, load_address)

    :ok
  end
end
