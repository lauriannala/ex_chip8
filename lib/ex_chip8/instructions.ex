defmodule ExChip8.Instructions do
  alias ExChip8.State
  alias ExChip8.Screen
  alias ExChip8.Stack

  import Bitwise

  def exec(%State{} = state, opcode) do
    nnn = opcode &&& 0x0FFF
    x = (opcode >>> 8) &&& 0x00F
    y = (opcode >>> 4) &&& 0x00F
    kk = opcode &&& 0x00FF
    n = opcode &&& 0x000F
    final_four_bits = opcode &&& 0x00F

    {instruction, updated_state} = _exec(state, opcode, %{
      nnn: nnn,
      x: x,
      y: y,
      kk: kk,
      n: n,
      final_four_bits: final_four_bits
    })

    updated_state
    |> Map.replace!(:instruction, instruction)
  end

  # CLS - Clear the display.
  defp _exec(%State{} = state, 0x00E0, _) do
    updated_screen = Screen.screen_clear(state.screen)

    {"CLS", Map.replace!(state, :screen, updated_screen)}
  end

  # RET - Return from subroutine.
  defp _exec(%State{} = state, 0x00EE, _) do
    {updated_state, pc} = Stack.stack_pop(state)

    updated_registers = Map.replace!(updated_state.registers, :pc, pc)

    {"RET", Map.replace!(updated_state, :registers, updated_registers)}
  end

  # JP addr - 1nnn, Jump to location nnn.
  defp _exec(%State{} = state, opcode, %{
    nnn: nnn
  }) when (opcode &&& 0xF000) == 0x1000  do

    updated_registers = Map.replace!(state.registers, :pc, nnn)

    {"JP addr - nnn: #{Integer.to_charlist(nnn, 16)}", Map.replace!(state, :registers, updated_registers)}
  end

  # CALL addr - 2nnn, Call subroutine at location nnn.
  defp _exec(%State{} = state, opcode, %{
    nnn: nnn
  }) when (opcode &&& 0xF000) == 0x2000 do

    updated_state = Stack.stack_push(state, state.registers.pc)
    updated_registers = Map.replace!(updated_state.registers, :pc, nnn)

    {"CALL addr - nnn: #{Integer.to_charlist(nnn, 16)}", Map.replace!(updated_state, :registers, updated_registers)}
  end

  # SE Vx, byte - 3xkk, Skip next instruction if Vx=kk.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    kk: kk
  }) when (opcode &&& 0xF000) == 0x3000 do
    reg_val = Enum.at(state.registers.v, x)

    updated_registers = case reg_val == kk do
      true ->
        Map.update!(state.registers, :pc, fn counter -> counter + 2 end)
      false ->
        state.registers
    end

    {
      "SE Vx - byte, x: #{Integer.to_charlist(x, 16)}, kk: #{Integer.to_charlist(kk, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # TODO
  # SE Vx, byte - 4xkk, Skip next instruction if Vx!=kk.

  defp _exec(%State{} = state, _opcode, _) do
    {"UNKNOWN", state}
  end
end
