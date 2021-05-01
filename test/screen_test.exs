defmodule ExChip8.ScreenTest do
  use ExUnit.Case

  alias ExChip8.Screen
  alias ExChip8.State

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

  defp initialize(_) do
    state = Screen.init_state(
      %State{},
      sleep_wait_period: 5,
      chip8_height: 32,
      chip8_width: 64
    )
    %{state: state}
  end
end
