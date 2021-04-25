defmodule ExChip8.RegisterTest do
  use ExUnit.Case

  alias ExChip8.State
  alias ExChip8.Registers

  describe "Registers" do
    test "init/2 initializes registers" do
      v_size = 100
      state = Registers.init(%State{}, v_size)
      assert length(state.registers.v) == v_size
    end
  end
end
