defmodule ExChip8.Instructions do
  alias ExChip8.State

  def exec(%State{} = state, _opcode) do
    state
  end
end
