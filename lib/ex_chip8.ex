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
    ?0, ?1, ?2, ?3, ?4, ?5,
    ?6, ?7, ?8, ?9, ?a, ?b,
    ?c, ?d, ?e, ?f
  ]

  @default_character_set Application.get_env(:ex_chip8, :chip8_default_character_set)

  def start(filename) do
    state =
      %State{}
      |> create_state(filename)
      |> init(@default_character_set)

    ExChip8.Screen.init_screen()


    # Testing start

    %{collision: _, screen: updated_screen} =
      ExChip8.Screen.screen_draw_sprite(%{
        screen: state.screen,
        x: 62,
        y: 30,
        memory: state.memory,
        sprite: 0x00,
        num: 5
      })
    state = Map.put(state, :screen, updated_screen)

    updated_registers =
      state.registers
      |> Map.put(:delay_timer, 15)
      |> Map.put(:sound_timer, 30)
    state = Map.put(state, :registers, updated_registers)

    # Testing end

    Stream.cycle([0])
    |> Enum.reduce(state, fn (_, updated_state) ->
      ExChip8.Screen.draw(updated_state)
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
    sliced = Enum.slice(
      state.memory.memory, -(length(state.memory.memory) - length(character_set)), length(state.memory.memory))

    memory_with_character_set = character_set ++ sliced

    updated_memory = Map.put(state.memory, :memory, memory_with_character_set)

    Map.put(state, :memory, updated_memory)
  end
end
