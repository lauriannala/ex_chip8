defmodule ExChip8.RegisterTest do
  use ExUnit.Case

  alias ExChip8.{Screen, Memory, Registers, Stack, Keyboard}
  alias ExChip8.Registers

  describe "Registers" do
    test "init/2 initializes registers" do
      v_size = 100

      {_, _, _, _, _} = Registers.init({%Screen{}, %Memory{}, nil, %Stack{}, %Keyboard{}}, v_size)

      assert :ets.info(:v_register)[:size] == v_size
    end
  end
end
