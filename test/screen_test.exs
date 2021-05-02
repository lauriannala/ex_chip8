defmodule ExChip8.ScreenTest do
  use ExUnit.Case

  alias ExChip8.Screen
  alias ExChip8.State

  @chip8_memory_size Application.get_env(:ex_chip8, :chip8_memory_size)
  @default_character_set Application.get_env(:ex_chip8, :chip8_default_character_set)

  describe "Unitialized screen" do
    test "init_state/2 initializes correctly" do
      state = Screen.init_state(
        %State{},
        sleep_wait_period: 5,
        chip8_height: 32,
        chip8_width: 64
      )

      assert state.screen.sleep_wait_period == 5
      assert state.screen.chip8_height == 32
      assert state.screen.chip8_width == 64

      assert Enum.at(state.screen.pixels, 0) ==
        Enum.map(1..64, fn _ -> false end)

      assert Enum.at(state.screen.pixels, 31) ==
        Enum.map(1..64, fn _ -> false end)
    end
  end

  describe "Initialized screen" do
    setup [:initialize]
    test "screen_is_set?/3 return correct status", %{state: state} do
      assert Screen.screen_is_set?(state.screen, 0, 0) == false
      assert Screen.screen_is_set?(state.screen, 63, 31) == false
    end

    test "screen_is_set?/3 raises when out of bounds", %{state: state} do
      assert_raise RuntimeError, fn ->
        Screen.screen_is_set?(state.screen, 64, 0)
      end

      assert_raise RuntimeError, fn ->
        Screen.screen_is_set?(state.screen, 0, 32)
      end
    end

    test "screen_set/3 updates pixel correctly", %{state: state} do
      updated_screen = Screen.screen_set(state.screen, 10, 15)

      row = Enum.at(updated_screen.pixels, 15)
      assert Enum.at(row, 10) == true

      assert (Enum.filter(row, fn val -> val == false end)
      |> length()) == 63
    end
  end

  describe "Initialized screen with memory" do
    setup [:initialize_with_memory]

    test "screen_draw_sprite_changeset/1 sets changes correctly", %{state: state} do
      draw = fn ->
        Screen.screen_draw_sprite_changeset(%{
          screen: state.screen,
          x: 32,
          y: 30,
          memory: state.memory,
          sprite: 0x00,
          num: 1
        })
      end

      result = draw.()

      assert result == [
        update: %{collision: false, pixel: true, x: 32, y: 30},
        update: %{collision: false, pixel: true, x: 33, y: 30},
        update: %{collision: false, pixel: true, x: 34, y: 30},
        update: %{collision: false, pixel: true, x: 35, y: 30}
      ]
    end

    test "screen_draw_sprite_changeset/1 sets collision correctly", %{state: state} do

      screen_has_pixels =
        state.screen
        |> Screen.screen_set(0, 0)
        |> Screen.screen_set(1, 0)

      result = Screen.screen_draw_sprite_changeset(%{
        screen: screen_has_pixels,
        x: 0,
        y: 0,
        memory: state.memory,
        sprite: 0x00,
        num: 1
      })

      assert result == [
        update: %{collision: true, pixel: false, x: 0, y: 0},
        update: %{collision: true, pixel: false, x: 1, y: 0},
        update: %{collision: false, pixel: true, x: 2, y: 0},
        update: %{collision: false, pixel: true, x: 3, y: 0}
      ]
    end
  end

  defp initialize(_) do
    state = Screen.init_state(
      %State{},
      sleep_wait_period: 5,
      chip8_height: 32,
      chip8_width: 64
    )
    %{state: state}
  end

  defp initialize_with_memory(_) do
    %{state: state} = initialize(%{})
    state =
      state
      |> ExChip8.Memory.init(@chip8_memory_size)
      |> ExChip8.init(@default_character_set)
    %{state: state}
  end
end
