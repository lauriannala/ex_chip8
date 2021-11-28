defmodule ExChip8 do
  alias ExChip8.State

  @chip8_width Application.get_env(:ex_chip8, :chip8_width)
  @chip8_height Application.get_env(:ex_chip8, :chip8_height)
  @sleep_wait_period Application.get_env(:ex_chip8, :sleep_wait_period)
  @chip8_memory_size Application.get_env(:ex_chip8, :chip8_memory_size)
  @chip8_total_data_registers Application.get_env(:ex_chip8, :chip8_total_data_registers)
  @chip8_total_stack_depth Application.get_env(:ex_chip8, :chip8_total_stack_depth)
  @chip8_total_keys Application.get_env(:ex_chip8, :chip8_total_keys)

  @keyboard_map [
    ?0,
    ?1,
    ?2,
    ?3,
    ?4,
    ?5,
    ?6,
    ?7,
    ?8,
    ?9,
    ?a,
    ?b,
    ?c,
    ?d,
    ?e,
    ?f
  ]

  @default_character_set Application.get_env(:ex_chip8, :chip8_default_character_set)
  @chip8_program_load_address Application.get_env(:ex_chip8, :chip8_program_load_address)

  def start(filename) do
    state =
      %State{}
      |> create_state(filename)
      |> init(@default_character_set)
      |> read_file_to_memory(@chip8_program_load_address)

    ExChip8.Screen.init_screen()

    # Testing start
    # state = Map.put(state, :screen, ExChip8.Screen.screen_set(state.screen, 0, 0))
    # state = Map.put(state, :screen, ExChip8.Screen.screen_set(state.screen, 1, 0))
    # state = Map.put(state, :screen, ExChip8.Screen.screen_set(state.screen, 2, 0))
    # Testing end

    Stream.cycle([0])
    |> Enum.reduce(state, fn _, updated_state ->
      opcode = ExChip8.Memory.memory_get_short(updated_state.memory, updated_state.registers.pc)
      # Testing start
      # opcode = 0xF165
      # Testing end

      next_cycle =
        updated_state
        |> ExChip8.Instructions.exec(opcode)

      case next_cycle do
        :wait_for_key_press ->
          updated_state
          |> ExChip8.Screen.draw(opcode)

        _ ->
          next_cycle
          |> ExChip8.Screen.draw(opcode)
          |> Map.update!(:registers, &Map.update!(&1, :pc, fn counter -> counter + 2 end))
      end
    end)
  end

  def create_state(%State{} = state), do: create_state(state, "GAME")

  def create_state(%State{} = state, filename) do
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
    |> Map.put(:filename, String.to_charlist(filename))
  end

  def init(%State{} = state, character_set) do
    sliced =
      Enum.slice(
        state.memory.memory,
        -(length(state.memory.memory) - length(character_set)),
        length(state.memory.memory)
      )

    memory_with_character_set = character_set ++ sliced

    updated_memory = Map.put(state.memory, :memory, memory_with_character_set)

    Map.put(state, :memory, updated_memory)
  end

  def read_file_to_memory(%State{} = state, load_address) do
    game_binary = File.read!(state.filename)
    game_bytes = :binary.bin_to_list(game_binary)

    updated_memory =
      game_bytes
      |> Enum.with_index()
      |> Enum.reduce(state.memory, fn {byte, byte_index}, memory ->
        index = byte_index + load_address
        ExChip8.Memory.memory_set(memory, index, byte)
      end)

    updated_registers =
      state.registers
      |> Map.put(:pc, load_address)

    state
    |> Map.put(:memory, updated_memory)
    |> Map.put(:registers, updated_registers)
  end
end
