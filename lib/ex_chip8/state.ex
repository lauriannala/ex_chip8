defmodule ExChip8.State do
  defmacro __using__(_) do
    quote do
      alias ExChip8.StateServer

      @v_register :v_register
      @registers :registers
      @memory :memory
      @stack :stack
    end
  end
end
