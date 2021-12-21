defmodule ExChip8.Instructions do
  alias ExChip8.Screen
  alias ExChip8.Stack

  import Bitwise

  require Logger

  @chip8_default_sprite_height Application.get_env(:ex_chip8, :chip8_default_sprite_height)

  def exec(state, opcode) do
    nnn = opcode &&& 0x0FFF
    x = opcode >>> 8 &&& 0x000F
    y = opcode >>> 4 &&& 0x000F
    kk = opcode &&& 0x00FF
    n = opcode &&& 0x000F

    exec_result =
      _exec(state, opcode, %{
        nnn: nnn,
        x: x,
        y: y,
        kk: kk,
        n: n
      })

    case exec_result do
      :wait_for_key_press ->
        :wait_for_key_press

      updated_state ->
        updated_state
    end
  end

  # CLS - Clear the display.
  defp _exec({screen, memory, registers, stack, keyboard}, 0x00E0, _) do
    updated_screen = Screen.screen_clear(screen)

    {updated_screen, memory, registers, stack, keyboard}
  end

  # RET - Return from subroutine.
  defp _exec({screen, memory, registers, stack, keyboard}, 0x00EE, _) do
    {updated_registers, pc} = Stack.stack_pop({stack, registers})

    updated_registers = Map.replace!(updated_registers, :pc, pc)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # JP addr - 1nnn, Jump to location nnn.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         nnn: nnn
       })
       when (opcode &&& 0xF000) == 0x1000 do
    updated_registers = Map.replace!(registers, :pc, nnn)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # CALL addr - 2nnn, Call subroutine at location nnn.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         nnn: nnn
       })
       when (opcode &&& 0xF000) == 0x2000 do
    {updated_stack, updated_registers} = Stack.stack_push({stack, registers}, registers.pc)
    updated_registers = Map.replace!(updated_registers, :pc, nnn)

    {screen, memory, updated_registers, updated_stack, keyboard}
  end

  # SE Vx, byte - 3xkk, Skip next instruction if Vx=kk.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         kk: kk
       })
       when (opcode &&& 0xF000) == 0x3000 do
    vx = Enum.at(registers.v, x)

    updated_registers =
      case vx == kk do
        true ->
          Map.update!(registers, :pc, fn counter -> counter + 2 end)

        false ->
          registers
      end

    {screen, memory, updated_registers, stack, keyboard}
  end

  # SE Vx, byte - 4xkk, Skip next instruction if Vx!=kk.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         kk: kk
       })
       when (opcode &&& 0xF000) == 0x4000 do
    reg_val = Enum.at(registers.v, x)

    updated_registers =
      case reg_val != kk do
        true ->
          Map.update!(registers, :pc, fn counter -> counter + 2 end)

        false ->
          registers
      end

    {screen, memory, updated_registers, stack, keyboard}
  end

  # SE Vx, Vy - 5xy0, Skip next instruction if Vx == Vy.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF000) == 0x5000 do
    vx = Enum.at(registers.v, x)
    vy = Enum.at(registers.v, y)

    updated_registers =
      case vx == vy do
        true ->
          Map.update!(registers, :pc, fn counter -> counter + 2 end)

        false ->
          registers
      end

    {screen, memory, updated_registers, stack, keyboard}
  end

  # LD Vx, byte - 6xkk, Vx = kk.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         kk: kk
       })
       when (opcode &&& 0xF000) == 0x6000 do
    updated_v_register = List.replace_at(registers.v, x, kk)
    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # ADD Vx, byte - 7xkk, Set Vx = Vx + kk.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         kk: kk
       })
       when (opcode &&& 0xF000) == 0x7000 do
    updated_v_register =
      List.update_at(registers.v, x, fn v ->
        sum = v + kk
        <<to_8_bit_int::8>> = <<sum::8>>
        to_8_bit_int
      end)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # LD Vx, Vy - 8xy0, Vx = Vy.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8000 do
    y_value = Enum.at(registers.v, y)
    updated_v_register = List.replace_at(registers.v, x, y_value)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # OR Vx, Vy - 8xy1, Performs an bitwise OR on Vx and Vy and stores the result in Vx.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8001 do
    y_value = Enum.at(registers.v, y)

    updated_v_register = List.update_at(registers.v, x, fn x_value -> x_value ||| y_value end)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  #  AND Vx, Vy - 8xy2, Performs an bitwise AND on Vx and Vy and stores the result in Vx.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8002 do
    y_value = Enum.at(registers.v, y)

    updated_v_register = List.update_at(registers.v, x, fn x_value -> x_value &&& y_value end)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # XOR Vx, Vy - 8xy3, Performs an bitwise XOR on Vx and Vy and stores the result in Vx.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8003 do
    y_value = Enum.at(registers.v, y)

    updated_v_register = List.update_at(registers.v, x, fn x_value -> bxor(x_value, y_value) end)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # ADD Vx, Vy - 8xy4, Set Vx = Vx + Vy, set VF = carry.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8004 do
    y_value = Enum.at(registers.v, y)

    updated_x = Enum.at(registers.v, x) + y_value

    updated_vf = updated_x > 0xFF

    updated_v_register =
      registers.v
      |> List.replace_at(x, updated_x)
      |> List.replace_at(0x0F, updated_vf)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # SUB Vx, Vy - 8xy5, Set Vx = Vx - Vy, set VF = Not borrow.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8005 do
    y_value = Enum.at(registers.v, y)
    x_value = Enum.at(registers.v, x)

    updated_x = x_value - y_value

    updated_vf = x_value > y_value

    updated_v_register =
      registers.v
      |> List.replace_at(x, updated_x)
      |> List.replace_at(0x0F, updated_vf)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # SHR Vx {, Vy} - 8xy6.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF00F) == 0x8006 do
    x_value = Enum.at(registers.v, x)

    updated_x = div(x_value, 2)

    updated_vf = x_value &&& 0x01

    updated_v_register =
      registers.v
      |> List.replace_at(x, updated_x)
      |> List.replace_at(0x0F, updated_vf)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # SUBN Vx, Vy - 8xy7.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8007 do
    y_value = Enum.at(registers.v, y)
    x_value = Enum.at(registers.v, x)

    updated_vf = y_value > x_value
    updated_x = y_value - x_value

    updated_v_register =
      registers.v
      |> List.replace_at(x, updated_x)
      |> List.replace_at(0x0F, updated_vf)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # SHL Vx {, Vy} - 8xyE.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF00F) == 0x800E do
    vx = Enum.at(registers.v, x)

    updated_vf = vx &&& 0b10000000
    updated_x = vx * 2

    updated_v_register =
      registers.v
      |> List.replace_at(x, updated_x)
      |> List.replace_at(0x0F, updated_vf)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # SNE Vx, Vy - 9xy0, Skip next instruction if Vx != Vy.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF000) == 0x9000 do
    vx = Enum.at(registers.v, x)
    vy = Enum.at(registers.v, y)

    updated_registers =
      case vx != vy do
        true ->
          Map.update!(registers, :pc, fn counter -> counter + 2 end)

        false ->
          registers
      end

    {screen, memory, updated_registers, stack, keyboard}
  end

  # LD I, addr - Annn, Sets the I register to nnn.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         nnn: nnn
       })
       when (opcode &&& 0xF000) == 0xA000 do
    updated_registers = Map.replace!(registers, :i, nnn)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # RND Vx, byte - Cxkk
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         kk: kk
       })
       when (opcode &&& 0xF000) == 0xC000 do
    updated_x = :rand.uniform(255) &&& kk

    updated_v_register =
      registers.v
      |> List.replace_at(x, updated_x)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # DRW Vx, Vy, nibble - Dxyn, Draws sprite to the screen.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x,
         y: y,
         n: n
       })
       when (opcode &&& 0xF000) == 0xD000 do
    sprite_index = registers.i

    %{collision: updated_vf, screen: updated_screen} =
      Screen.screen_draw_sprite(%{
        screen: screen,
        x: Enum.at(registers.v, x),
        y: Enum.at(registers.v, y),
        memory: memory,
        sprite_index: sprite_index,
        num: n
      })

    updated_v_register =
      registers.v
      |> List.replace_at(0x0F, boolean_to_integer(updated_vf))

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {updated_screen, memory, updated_registers, stack, keyboard}
  end

  # SKP Vx - Ex9E, Skip the next instruction if the key with the value of Vx is pressed.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xE09E do
    vx = Enum.at(registers.v, x)

    updated_registers =
      case ExChip8.Keyboard.keyboard_is_down(keyboard, vx) do
        true ->
          Map.update!(registers, :pc, fn counter -> counter + 2 end)

        false ->
          registers
      end

    {screen, memory, updated_registers, stack, keyboard}
  end

  # SKP Vx - ExA1, Skip the next instruction if the key with the value of Vx is NOT pressed.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xE0A1 do
    vx = Enum.at(registers.v, x)

    updated_registers =
      case not ExChip8.Keyboard.keyboard_is_down(keyboard, vx) do
        true ->
          Map.update!(registers, :pc, fn counter -> counter + 2 end)

        false ->
          registers
      end

    {screen, memory, updated_registers, stack, keyboard}
  end

  # LD Vx, DT - Fx07, Set Vx to the delay timer value.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF007 do
    updated_x = registers.delay_timer

    updated_v_register =
      registers.v
      |> List.replace_at(x, updated_x)

    updated_registers = Map.replace!(registers, :v, updated_v_register)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # LD Vx, K - fx0A.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF00A do
    pressed_key = keyboard.pressed_key
    pressed_key_index = ExChip8.Keyboard.keyboard_map(keyboard, pressed_key)

    case pressed_key_index do
      false ->
        :wait_for_key_press

      _ ->
        updated_v_register =
          registers.v
          |> List.replace_at(x, pressed_key_index)

        updated_registers = Map.replace!(registers, :v, updated_v_register)

        {screen, memory, updated_registers, stack, keyboard}
    end
  end

  # LD CT, Vx, K - Fx15, Set delay_timer to Vx.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF015 do
    vx = Enum.at(registers.v, x)

    updated_registers = Map.replace!(registers, :delay_timer, vx)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # LD ST, Vx, K - Fx18, Set sound_timer to Vx.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF018 do
    vx = Enum.at(registers.v, x)

    updated_registers = Map.replace!(registers, :sound_timer, vx)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # ADD I, Vx - Fx1E.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF01E do
    vx = Enum.at(registers.v, x)

    updated_registers =
      registers
      |> Map.update!(:i, fn i_value -> i_value + vx end)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # LD F, Vx - Fx29.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF029 do
    vx = Enum.at(registers.v, x)

    updated_registers =
      registers
      |> Map.replace!(:i, vx * @chip8_default_sprite_height)

    {screen, memory, updated_registers, stack, keyboard}
  end

  # LD B, Vx - Fx33.
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF033 do
    vx = Enum.at(registers.v, x)

    hundreds = vx |> div(100)
    tens = vx |> div(10) |> rem(10)
    units = vx |> rem(10)

    updated_memory =
      memory
      |> ExChip8.Memory.memory_set(registers.i, hundreds)
      |> ExChip8.Memory.memory_set(registers.i + 1, tens)
      |> ExChip8.Memory.memory_set(registers.i + 2, units)

    {screen, updated_memory, registers, stack, keyboard}
  end

  # LD [I], Vx - Fx55
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF055 do
    updated_memory =
      0..(x - 1)
      |> Enum.reduce(memory, fn i, updated_memory ->
        vi = Enum.at(registers.v, i)

        updated_memory
        |> ExChip8.Memory.memory_set(registers.i + i, vi)
      end)

    {screen, updated_memory, registers, stack, keyboard}
  end

  # LD Vx, [I] - Fx65
  defp _exec({screen, memory, registers, stack, keyboard}, opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF065 do
    updated_registers =
      0..(x - 1)
      |> Enum.reduce(registers, fn i, updated_registers ->
        value_from_memory = ExChip8.Memory.memory_get(memory, registers.i + 1)

        updated_v_register =
          registers.v
          |> List.replace_at(i, value_from_memory)

        Map.replace!(updated_registers, :v, updated_v_register)
      end)

    {screen, memory, updated_registers, stack, keyboard}
  end

  defp _exec(_, opcode, _) do
    raise "UNKNOWN: #{Integer.to_charlist(opcode, 16)}"
  end

  defp boolean_to_integer(true), do: 1
  defp boolean_to_integer(false), do: 0
end
