defmodule ExChip8.StateServer do
  use GenServer

  @default_state :ok
  @v_register :v_register

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

    {:ok, state}
  end

  def lookup_v_register(index) do
    GenServer.call(__MODULE__, {:lookup_v_register, index})
  end

  def insert_v_register(index, value) do
    GenServer.call(__MODULE__, {:insert_v_register, index, value})
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
end
