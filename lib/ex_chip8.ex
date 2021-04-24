defmodule ExChip8 do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    state = Screen.init(%{})

    {:ok, state}
  end
end
