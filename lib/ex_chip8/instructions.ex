defmodule ExChip8.Instructions do
  alias ExChip8.State
  alias ExChip8.Screen

  def exec(%State{} = state, opcode) do
    {instruction, updated_state} = _exec(state, opcode)

    updated_state
    |> Map.replace!(:instruction, instruction)
  end

  # CLS - Clear the display.
  defp _exec(%State{} = state, 0x00E0) do
    updated_screen = Screen.screen_clear(state.screen)

    {"CLS", Map.put(state, :screen, updated_screen)}
  end

  defp _exec(%State{} = state, _opcode) do
    {"UNKNOWN", state}
  end
end
