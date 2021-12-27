defmodule ExChip8 do
  @chip8_width Application.get_env(:ex_chip8, :chip8_width)
  @chip8_height Application.get_env(:ex_chip8, :chip8_height)
  @sleep_wait_period Application.get_env(:ex_chip8, :sleep_wait_period)
  @chip8_memory_size Application.get_env(:ex_chip8, :chip8_memory_size)
  @chip8_total_data_registers Application.get_env(:ex_chip8, :chip8_total_data_registers)
  @chip8_total_stack_depth Application.get_env(:ex_chip8, :chip8_total_stack_depth)
  @chip8_total_keys Application.get_env(:ex_chip8, :chip8_total_keys)

  @keyboard_map [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F"
  ]

  alias ExChip8.Registers

  def create_state(state), do: create_state(state, "GAME")

  def create_state(state, filename) do
    state =
      state
      |> ExChip8.Screen.init_state(
        sleep_wait_period: @sleep_wait_period,
        chip8_height: @chip8_height,
        chip8_width: @chip8_width
      )
      |> ExChip8.Memory.init(@chip8_memory_size)
      |> ExChip8.Registers.init(@chip8_total_data_registers)
      |> ExChip8.Stack.init(@chip8_total_stack_depth)
      |> ExChip8.Keyboard.init(@chip8_total_keys)
      |> ExChip8.Keyboard.keyboard_set_map(@keyboard_map)

    {:ok, state, String.to_charlist(filename)}
  end

  def init({:ok, {screen, memory, registers, stack, keyboard}, filename}, character_set) do
    sliced =
      Enum.slice(
        memory.memory,
        -(length(memory.memory) - length(character_set)),
        length(memory.memory)
      )

    memory_with_character_set = [character_set | sliced] |> List.flatten()

    updated_memory = Map.put(memory, :memory, memory_with_character_set)

    {:ok, {screen, updated_memory, registers, stack, keyboard}, filename}
  end

  def read_file_to_memory(
        {:ok, {screen, memory, registers, stack, keyboard}, filename},
        load_address
      ) do
    game_binary = File.read!(filename)
    game_bytes = :binary.bin_to_list(game_binary)

    updated_memory =
      game_bytes
      |> Enum.with_index()
      |> Enum.reduce(memory, fn {byte, byte_index}, memory ->
        index = byte_index + load_address
        ExChip8.Memory.memory_set(memory, index, byte)
      end)

    Registers.insert_register(:pc, load_address)

    {screen, updated_memory, registers, stack, keyboard}
  end
end
