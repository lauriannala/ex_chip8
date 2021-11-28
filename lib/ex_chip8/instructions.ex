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

    {instruction, updated_state} = _exec(state, opcode, %{
      nnn: nnn,
      x: x,
      y: y,
      kk: kk,
      n: n
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
      "SE Vx (3xkk) - byte, x: #{Integer.to_charlist(x, 16)}, kk: #{Integer.to_charlist(kk, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # SE Vx, byte - 4xkk, Skip next instruction if Vx!=kk.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    kk: kk
  }) when (opcode &&& 0xF000) == 0x4000 do
    reg_val = Enum.at(state.registers.v, x)

    updated_registers = case reg_val != kk do
      true ->
        Map.update!(state.registers, :pc, fn counter -> counter + 2 end)
      false ->
        state.registers
    end

    {
      "SE Vx (4xkk) - byte, x: #{Integer.to_charlist(x, 16)}, kk: #{Integer.to_charlist(kk, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # SE Vx, Vy - 5xy0, Skip next instruction if Vx == Vy.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    y: y
  }) when (opcode &&& 0xF000) == 0x5000 do
    vx = Enum.at(state.registers.v, x)
    vy = Enum.at(state.registers.v, y)

    updated_registers = case vx == vy do
      true ->
        Map.update!(state.registers, :pc, fn counter -> counter + 2 end)
      false ->
        state.registers
    end

    {
      "SE Vx, Vy (5xy0) - byte, x: #{Integer.to_charlist(x, 16)}, y: #{Integer.to_charlist(y, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # LD Vx, byte - 6xkk, Vx = kk.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    kk: kk
  }) when (opcode &&& 0xF000) == 0x6000 do
    updated_v_register = List.replace_at(state.registers.v, x, kk)
    updated_registers = Map.replace!(state.registers, :v, updated_v_register)

    {
      "LD Vx, byte, x: #{Integer.to_charlist(x, 16)}, kk: #{Integer.to_charlist(kk, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # ADD Vx, byte - 7xkk, Set Vx = Vx + kk.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    kk: kk
  }) when (opcode &&& 0xF000) == 0x7000 do
    updated_v_register = List.update_at(state.registers.v, x, fn v -> v + kk end)
    updated_registers = Map.replace!(state.registers, :v, updated_v_register)

    {
      "ADD Vx, byte, x: #{Integer.to_charlist(x, 16)}, kk: #{Integer.to_charlist(kk, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # LD Vx, Vy - 8xy0, Vx = Vy.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    y: y
  }) when (opcode &&& 0xF00F) == 0x8000 do
    y_value = Enum.at(state.registers.v, y)
    updated_v_register = List.replace_at(state.registers.v, x, y_value)

    updated_registers = Map.replace!(state.registers, :v, updated_v_register)

    {
      "LD Vx, Vy, x: #{Integer.to_charlist(x, 16)}, y: #{Integer.to_charlist(y, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # OR Vx, Vy - 8xy1, Performs an bitwise OR on Vx and Vy and stores the result in Vx.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    y: y
  }) when (opcode &&& 0xF00F) == 0x8001 do
    y_value = Enum.at(state.registers.v, y)
    updated_v_register =
      List.update_at(state.registers.v, x, fn x_value -> x_value ||| y_value end)

    updated_registers = Map.replace!(state.registers, :v, updated_v_register)

    {
      "OR Vx, Vy, x: #{Integer.to_charlist(x, 16)}, y: #{Integer.to_charlist(y, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  #  AND Vx, Vy - 8xy2, Performs an bitwise AND on Vx and Vy and stores the result in Vx.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    y: y
  }) when (opcode &&& 0xF00F) == 0x8002 do
    y_value = Enum.at(state.registers.v, y)
    updated_v_register =
      List.update_at(state.registers.v, x, fn x_value -> x_value &&& y_value end)

    updated_registers = Map.replace!(state.registers, :v, updated_v_register)

    {
      "AND Vx, Vy, x: #{Integer.to_charlist(x, 16)}, y: #{Integer.to_charlist(y, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # XOR Vx, Vy - 8xy3, Performs an bitwise XOR on Vx and Vy and stores the result in Vx.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    y: y
  }) when (opcode &&& 0xF00F) == 0x8003 do
    y_value = Enum.at(state.registers.v, y)
    updated_v_register =
      List.update_at(state.registers.v, x, fn x_value -> x_value ^^^ y_value end)

    updated_registers = Map.replace!(state.registers, :v, updated_v_register)

    {
      "XOR Vx, Vy, x: #{Integer.to_charlist(x, 16)}, y: #{Integer.to_charlist(y, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # ADD Vx, Vy - 8xy4, Set Vx = Vx + Vy, set VF = carry.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    y: y
  }) when (opcode &&& 0xF00F) == 0x8004 do
    y_value = Enum.at(state.registers.v, y)

    updated_x = Enum.at(state.registers.v, x) + y_value

    updated_vf = updated_x > 0xFF

    updated_v_register =
      state.registers.v
      |> List.replace_at(x, updated_x)
      |> List.replace_at(0x0F, updated_vf)

    updated_registers = Map.replace!(state.registers, :v, updated_v_register)

    {
      "ADD Vx, Vy, x: #{Integer.to_charlist(x, 16)}, y: #{Integer.to_charlist(y, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # SUB Vx, Vy - 8xy5, Set Vx = Vx - Vy, set VF = Not borrow.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    y: y
  }) when (opcode &&& 0xF00F) == 0x8005 do
    y_value = Enum.at(state.registers.v, y)
    x_value = Enum.at(state.registers.v, x)

    updated_x = x_value - y_value

    updated_vf = x_value > y_value

    updated_v_register =
      state.registers.v
      |> List.replace_at(x, updated_x)
      |> List.replace_at(0x0F, updated_vf)

    updated_registers = Map.replace!(state.registers, :v, updated_v_register)

    {
      "SUB Vx, Vy, x: #{Integer.to_charlist(x, 16)}, y: #{Integer.to_charlist(y, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # SHR Vx {, Vy} - 8xy6.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    y: y
  }) when (opcode &&& 0xF00F) == 0x8006 do
    x_value = Enum.at(state.registers.v, x)

    updated_x = div(x_value, 2)

    updated_vf = x_value &&& 0x01

    updated_v_register =
      state.registers.v
      |> List.replace_at(x, updated_x)
      |> List.replace_at(0x0F, updated_vf)

    updated_registers = Map.replace!(state.registers, :v, updated_v_register)
    {
      "SHR Vx, Vy, x: #{Integer.to_charlist(x, 16)}, y: #{Integer.to_charlist(y, 16)}", Map.replace!(state, :registers, updated_registers)
    }
  end

  # SUBN Vx, Vy - 8xy7.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    y: y
  }) when (opcode &&& 0xF00F) == 0x8007 do
    y_value = Enum.at(state.registers.v, y)
    x_value = Enum.at(state.registers.v, x)

    updated_vf = y_value > x_value;
    updated_x = y_value - x_value

    updated_v_register =
      state.registers.v
      |> List.replace_at(x, updated_x)
      |> List.replace_at(0x0F, updated_vf)

    updated_registers = Map.replace!(state.registers, :v, updated_v_register)
    {
      "SUBN Vx, Vy, x: #{Integer.to_charlist(x, 16)}, y: #{Integer.to_charlist(y, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  # SHL Vx {, Vy} - 8xyE.
  defp _exec(%State{} = state, opcode, %{
    x: x,
    y: y
  }) when (opcode &&& 0xF00F) == 0x800E do
    x_value = Enum.at(state.registers.v, x)

    updated_vf = x_value &&& 0b10000000;
    updated_x = x_value * 2

    updated_v_register =
      state.registers.v
      |> List.replace_at(x, updated_x)
      |> List.replace_at(0x0F, updated_vf)

    updated_registers = Map.replace!(state.registers, :v, updated_v_register)
    {
      "SHL Vx, Vy, x: #{Integer.to_charlist(x, 16)}, y: #{Integer.to_charlist(y, 16)}",
      Map.replace!(state, :registers, updated_registers)
    }
  end

  defp _exec(%State{} = state, opcode, _) do
    {"UNKNOWN: #{Integer.to_charlist(opcode, 16)}", state}
  end
end
