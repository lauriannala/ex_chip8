defmodule ExChip8.Instructions do
  alias ExChip8.{Screen, Stack, Registers, Keyboard, Memory}

  import Bitwise

  require Logger

  @chip8_default_sprite_height Application.compile_env!(:ex_chip8, :chip8_default_sprite_height)

  @moduledoc """
  Implements all chip8 instructions.

  Operation code is pattern matched to corresponding instruction implementation method.
  Mutations are immediately executed according to instruction specification.
  Uknown operation code raises.
  """

  @doc """
  Execute instruction associated with opcode.
  """
  @spec exec(integer) :: :ok | :wait_for_key_press
  def exec(opcode) do
    nnn = opcode &&& 0x0FFF
    x = opcode >>> 8 &&& 0x000F
    y = opcode >>> 4 &&& 0x000F
    kk = opcode &&& 0x00FF
    n = opcode &&& 0x000F

    case _exec(opcode, %{
           nnn: nnn,
           x: x,
           y: y,
           kk: kk,
           n: n
         }) do
      :wait_for_key_press -> :wait_for_key_press
      _ -> :ok
    end
  end

  # CLS - Clear the display.
  defp _exec(0x00E0, _) do
    Screen.get_screen()
    |> Screen.screen_clear()
  end

  # RET - Return from subroutine.
  defp _exec(0x00EE, _) do
    pc = Stack.stack_pop()
    Registers.insert_register(:pc, pc)
  end

  # JP addr - 1nnn, Jump to location nnn.
  defp _exec(opcode, %{
         nnn: nnn
       })
       when (opcode &&& 0xF000) == 0x1000 do
    Registers.insert_register(:pc, nnn)
  end

  # CALL addr - 2nnn, Call subroutine at location nnn.
  defp _exec(opcode, %{
         nnn: nnn
       })
       when (opcode &&& 0xF000) == 0x2000 do
    pc = Registers.lookup_register(:pc)
    Stack.stack_push(pc)

    Registers.insert_register(:pc, nnn)
  end

  # SE Vx, byte - 3xkk, Skip next instruction if Vx=kk.
  defp _exec(opcode, %{
         x: x,
         kk: kk
       })
       when (opcode &&& 0xF000) == 0x3000 do
    vx = Registers.lookup_v_register(x)

    if vx == kk do
      pc = Registers.lookup_register(:pc)
      Registers.insert_register(:pc, pc + 2)
    end
  end

  # SE Vx, byte - 4xkk, Skip next instruction if Vx!=kk.
  defp _exec(opcode, %{
         x: x,
         kk: kk
       })
       when (opcode &&& 0xF000) == 0x4000 do
    reg_val = Registers.lookup_v_register(x)

    if reg_val != kk do
      pc = Registers.lookup_register(:pc)
      Registers.insert_register(:pc, pc + 2)
    end
  end

  # SE Vx, Vy - 5xy0, Skip next instruction if Vx == Vy.
  defp _exec(opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF000) == 0x5000 do
    vx = Registers.lookup_v_register(x)
    vy = Registers.lookup_v_register(y)

    if vx == vy do
      pc = Registers.lookup_register(:pc)
      Registers.insert_register(:pc, pc + 2)
    end
  end

  # LD Vx, byte - 6xkk, Vx = kk.
  defp _exec(opcode, %{
         x: x,
         kk: kk
       })
       when (opcode &&& 0xF000) == 0x6000 do
    Registers.insert_v_register(x, kk)
  end

  # ADD Vx, byte - 7xkk, Set Vx = Vx + kk.
  defp _exec(opcode, %{
         x: x,
         kk: kk
       })
       when (opcode &&& 0xF000) == 0x7000 do
    v = Registers.lookup_v_register(x)
    sum = v + kk
    <<to_8_bit_int::8>> = <<sum::8>>
    Registers.insert_v_register(x, to_8_bit_int)
  end

  # LD Vx, Vy - 8xy0, Vx = Vy.
  defp _exec(opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8000 do
    y_value = Registers.lookup_v_register(y)
    Registers.insert_v_register(x, y_value)
  end

  # OR Vx, Vy - 8xy1, Performs an bitwise OR on Vx and Vy and stores the result in Vx.
  defp _exec(opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8001 do
    y_value = Registers.lookup_v_register(y)
    x_value = Registers.lookup_v_register(x)

    Registers.insert_v_register(x, x_value ||| y_value)
  end

  #  AND Vx, Vy - 8xy2, Performs an bitwise AND on Vx and Vy and stores the result in Vx.
  defp _exec(opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8002 do
    y_value = Registers.lookup_v_register(y)
    x_value = Registers.lookup_v_register(x)

    Registers.insert_v_register(x, x_value &&& y_value)
  end

  # XOR Vx, Vy - 8xy3, Performs an bitwise XOR on Vx and Vy and stores the result in Vx.
  defp _exec(opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8003 do
    y_value = Registers.lookup_v_register(y)
    x_value = Registers.lookup_v_register(x)

    Registers.insert_v_register(x, bxor(x_value, y_value))
  end

  # ADD Vx, Vy - 8xy4, Set Vx = Vx + Vy, set VF = carry.
  defp _exec(opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8004 do
    y_value = Registers.lookup_v_register(y)
    x_value = Registers.lookup_v_register(x)

    updated_x = x_value + y_value

    updated_vf = updated_x > 0xFF

    Registers.insert_v_register(x, updated_x)
    Registers.insert_v_register(0x0F, boolean_to_integer(updated_vf))
  end

  # SUB Vx, Vy - 8xy5, Set Vx = Vx - Vy, set VF = Not borrow.
  defp _exec(opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8005 do
    y_value = Registers.lookup_v_register(y)
    x_value = Registers.lookup_v_register(x)

    updated_x = x_value - y_value

    updated_vf = x_value > y_value

    Registers.insert_v_register(x, updated_x)
    Registers.insert_v_register(0x0F, boolean_to_integer(updated_vf))
  end

  # SHR Vx {, Vy} - 8xy6.
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF00F) == 0x8006 do
    x_value = Registers.lookup_v_register(x)

    updated_x = div(x_value, 2)

    updated_vf = x_value &&& 0x01

    Registers.insert_v_register(x, updated_x)
    Registers.insert_v_register(0x0F, updated_vf)
  end

  # SUBN Vx, Vy - 8xy7.
  defp _exec(opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF00F) == 0x8007 do
    y_value = Registers.lookup_v_register(y)
    x_value = Registers.lookup_v_register(x)

    updated_vf = y_value > x_value
    updated_x = y_value - x_value

    Registers.insert_v_register(x, updated_x)
    Registers.insert_v_register(0x0F, boolean_to_integer(updated_vf))
  end

  # SHL Vx {, Vy} - 8xyE.
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF00F) == 0x800E do
    x_value = Registers.lookup_v_register(x)

    updated_vf = x_value &&& 0b10000000
    updated_x = x_value * 2

    Registers.insert_v_register(x, updated_x)
    Registers.insert_v_register(0x0F, updated_vf)
  end

  # SNE Vx, Vy - 9xy0, Skip next instruction if Vx != Vy.
  defp _exec(opcode, %{
         x: x,
         y: y
       })
       when (opcode &&& 0xF000) == 0x9000 do
    y_value = Registers.lookup_v_register(y)
    x_value = Registers.lookup_v_register(x)

    if x_value != y_value do
      pc = Registers.lookup_register(:pc)
      Registers.insert_register(:pc, pc + 2)
    end
  end

  # LD I, addr - Annn, Sets the I register to nnn.
  defp _exec(opcode, %{
         nnn: nnn
       })
       when (opcode &&& 0xF000) == 0xA000 do
    Registers.insert_register(:i, nnn)
  end

  # RND Vx, byte - Cxkk
  defp _exec(opcode, %{
         x: x,
         kk: kk
       })
       when (opcode &&& 0xF000) == 0xC000 do
    updated_x = :rand.uniform(255) &&& kk

    Registers.insert_v_register(x, updated_x)
  end

  # DRW Vx, Vy, nibble - Dxyn, Draws sprite to the screen.
  defp _exec(opcode, %{
         x: x,
         y: y,
         n: n
       })
       when (opcode &&& 0xF000) == 0xD000 do
    sprite_index = Registers.lookup_register(:i)

    %{collision: updated_vf} =
      Screen.get_screen()
      |> Screen.screen_draw_sprite(%{
        x: Registers.lookup_v_register(x),
        y: Registers.lookup_v_register(y),
        sprite_index: sprite_index,
        num: n
      })

    Registers.insert_v_register(0x0F, boolean_to_integer(updated_vf))
  end

  # SKP Vx - Ex9E, Skip the next instruction if the key with the value of Vx is pressed.
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xE09E do
    x_value = Registers.lookup_v_register(x)

    if Keyboard.get_keyboard() |> Keyboard.keyboard_is_down(x_value) do
      pc = Registers.lookup_register(:pc)
      Registers.insert_register(:pc, pc + 2)
    end
  end

  # SKP Vx - ExA1, Skip the next instruction if the key with the value of Vx is NOT pressed.
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xE0A1 do
    x_value = Registers.lookup_v_register(x)

    if not (Keyboard.get_keyboard() |> Keyboard.keyboard_is_down(x_value)) do
      pc = Registers.lookup_register(:pc)
      Registers.insert_register(:pc, pc + 2)
    end
  end

  # LD Vx, DT - Fx07, Set Vx to the delay timer value.
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF007 do
    updated_x = Registers.lookup_register(:delay_timer)

    Registers.insert_v_register(x, updated_x)
  end

  # LD Vx, K - fx0A.
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF00A do
    keyboard = Keyboard.get_keyboard()

    pressed_key = keyboard.pressed_key
    pressed_key_index = Keyboard.keyboard_map(keyboard, pressed_key)

    case pressed_key_index do
      false ->
        :wait_for_key_press

      _ ->
        Registers.insert_v_register(x, pressed_key_index)
    end
  end

  # LD CT, Vx, K - Fx15, Set delay_timer to Vx.
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF015 do
    x_value = Registers.lookup_v_register(x)

    Registers.insert_register(:delay_timer, x_value)
  end

  # LD ST, Vx, K - Fx18, Set sound_timer to Vx.
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF018 do
    x_value = Registers.lookup_v_register(x)

    Registers.insert_register(:sound_timer, x_value)
  end

  # ADD I, Vx - Fx1E.
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF01E do
    x_value = Registers.lookup_v_register(x)

    i_value = Registers.lookup_register(:i)
    Registers.insert_register(:i, i_value + x_value)
  end

  # LD F, Vx - Fx29.
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF029 do
    x_value = Registers.lookup_v_register(x)

    Registers.insert_register(:i, x_value * @chip8_default_sprite_height)
  end

  # LD B, Vx - Fx33.
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF033 do
    x_value = Registers.lookup_v_register(x)

    hundreds = x_value |> div(100)
    tens = x_value |> div(10) |> rem(10)
    units = x_value |> rem(10)

    i_value = Registers.lookup_register(:i)

    Memory.insert_memory(i_value, hundreds)
    Memory.insert_memory(i_value + 1, tens)
    Memory.insert_memory(i_value + 2, units)
  end

  # LD [I], Vx - Fx55
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF055 do
    0..(x - 1)
    |> Enum.map(fn i ->
      vi = Registers.lookup_v_register(i)

      (Registers.lookup_register(:i) + i)
      |> Memory.insert_memory(vi)
    end)
  end

  # LD Vx, [I] - Fx65
  defp _exec(opcode, %{
         x: x
       })
       when (opcode &&& 0xF0FF) == 0xF065 do
    0..(x - 1)
    |> Enum.each(fn i ->
      i_value = Registers.lookup_register(:i)
      value_from_memory = Memory.lookup_memory(i_value + 1)

      Registers.insert_v_register(i, value_from_memory)
    end)
  end

  defp _exec(opcode, _) do
    raise "UNKNOWN: #{Integer.to_charlist(opcode, 16)}"
  end

  defp boolean_to_integer(true), do: 1
  defp boolean_to_integer(false), do: 0
end
