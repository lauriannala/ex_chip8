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
    end
  end
end
