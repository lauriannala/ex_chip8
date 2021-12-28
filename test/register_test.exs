defmodule ExChip8.RegisterTest do
  use ExChip8.StateCase

  alias ExChip8.{Screen, Registers, Keyboard}
  alias ExChip8.Registers

  describe "Registers" do
    test "init/2 initializes registers" do
      v_size = 100

      {_, _, _, _, _} = Registers.init({%Screen{}, nil, nil, nil, %Keyboard{}}, v_size)

      assert :ets.info(:v_register)[:size] == v_size
    end
  end
end
