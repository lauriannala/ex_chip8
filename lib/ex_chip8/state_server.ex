defmodule ExChip8.StateServer do
  use GenServer

  @default_state :ok
  @v_register :v_register
  @registers :registers
  @memory :memory
  @stack :stack

  def start_link(_) do
    GenServer.start_link(__MODULE__, @default_state, name: __MODULE__)
  end

  @impl true
  def init(state) do
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

    {:ok, state}
  end

  @impl true
  def handle_call({:lookup_v_register, index}, _pid, @default_state) do
    value = :ets.lookup(@v_register, index)
    {:reply, value, @default_state}
  end

  @impl true
  def handle_call({:insert_v_register, index, value}, _pid, @default_state) do
    :ets.insert(@v_register, {index, value})
    {:reply, value, @default_state}
  end

  @impl true
  def handle_call({:lookup_register, register}, _pid, @default_state) do
    value = :ets.lookup(@registers, register)
    {:reply, value, @default_state}
  end

  @impl true
  def handle_call({:insert_register, register, value}, _pid, @default_state) do
    :ets.insert(@registers, {register, value})
    {:reply, value, @default_state}
  end

  @impl true
  def handle_call({:lookup_memory, at}, _pid, @default_state) do
    value = :ets.lookup(@memory, at)
    {:reply, value, @default_state}
  end

  @impl true
  def handle_call({:insert_memory, at, value}, _pid, @default_state) do
    :ets.insert(@memory, {at, value})
    {:reply, value, @default_state}
  end

  @impl true
  def handle_call({:memory_all_values}, _pid, @default_state) do
    values = :ets.tab2list(@memory)
    {:reply, values, @default_state}
  end

  @impl true
  def handle_call({:lookup_stack, index}, _pid, @default_state) do
    value = :ets.lookup(@stack, index)
    {:reply, value, @default_state}
  end

  @impl true
  def handle_call({:insert_stack, index, value}, _pid, @default_state) do
    :ets.insert(@stack, {index, value})
    {:reply, value, @default_state}
  end
end
