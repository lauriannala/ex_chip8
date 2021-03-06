defmodule ExChip8.StateServer do
  use GenServer

  @chip8_width Application.get_env(:ex_chip8, :chip8_width)
  @chip8_height Application.get_env(:ex_chip8, :chip8_height)
  @sleep_wait_period Application.get_env(:ex_chip8, :sleep_wait_period)
  @chip8_total_keys Application.get_env(:ex_chip8, :chip8_total_keys)
  @default_state :ok
  @v_register :v_register
  @registers :registers
  @memory :memory
  @stack :stack

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

  @moduledoc """
  ### Overview

  Persists chip8-data in memory.
  GenServer-calls are used to manipulate and retrieve this data.

  ## ETS-tables

  * v_register
  * registers
  * memory
  * stack

  ## Elixir-maps
  * screen pixels
  * keyboard
  """

  def start_link(_) do
    GenServer.start_link(__MODULE__, @default_state, name: __MODULE__)
  end

  @impl true
  def init(_) do
    :ets.new(@v_register, [
      :set,
      :named_table,
      :public,
      read_concurrency: false,
      write_concurrency: false
    ])

    :ets.new(@registers, [
      :set,
      :named_table,
      :public,
      read_concurrency: false,
      write_concurrency: false
    ])

    :ets.new(@memory, [
      :set,
      :named_table,
      :public,
      read_concurrency: false,
      write_concurrency: false
    ])

    :ets.new(@stack, [
      :set,
      :named_table,
      :public,
      read_concurrency: false,
      write_concurrency: false
    ])

    screen =
      ExChip8.Screen.init_state(
        sleep_wait_period: @sleep_wait_period,
        chip8_height: @chip8_height,
        chip8_width: @chip8_width
      )

    keyboard =
      ExChip8.Keyboard.init(@chip8_total_keys)
      |> ExChip8.Keyboard.keyboard_set_map(@keyboard_map)

    state = %{screen: screen, keyboard: keyboard}

    {:ok, state}
  end

  @impl true
  def handle_call({:lookup_v_register, index}, _pid, state) do
    value = :ets.lookup(@v_register, index)
    {:reply, value, state}
  end

  @impl true
  def handle_call({:insert_v_register, index, value}, _pid, state) do
    :ets.insert(@v_register, {index, value})
    {:reply, value, state}
  end

  @impl true
  def handle_call({:lookup_register, register}, _pid, state) do
    value = :ets.lookup(@registers, register)
    {:reply, value, state}
  end

  @impl true
  def handle_call({:insert_register, register, value}, _pid, state) do
    :ets.insert(@registers, {register, value})
    {:reply, value, state}
  end

  @impl true
  def handle_call({:lookup_memory, at}, _pid, state) do
    value = :ets.lookup(@memory, at)
    {:reply, value, state}
  end

  @impl true
  def handle_call({:insert_memory, at, value}, _pid, state) do
    :ets.insert(@memory, {at, value})
    {:reply, value, state}
  end

  @impl true
  def handle_call({:memory_all_values}, _pid, state) do
    values = :ets.tab2list(@memory)
    {:reply, values, state}
  end

  @impl true
  def handle_call({:lookup_stack, index}, _pid, state) do
    value = :ets.lookup(@stack, index)
    {:reply, value, state}
  end

  @impl true
  def handle_call({:insert_stack, index, value}, _pid, state) do
    :ets.insert(@stack, {index, value})
    {:reply, value, state}
  end

  @impl true
  def handle_call({:get_screen}, _pid, state) do
    {:reply, state.screen, state}
  end

  @impl true
  def handle_call({:update_screen, screen}, _pid, state) do
    {:reply, screen, Map.replace!(state, :screen, screen)}
  end

  @impl true
  def handle_call({:get_keyboard}, _pid, state) do
    {:reply, state.keyboard, state}
  end

  @impl true
  def handle_call({:update_keyboard, keyboard}, _pid, state) do
    {:reply, keyboard, Map.replace!(state, :keyboard, keyboard)}
  end
end
