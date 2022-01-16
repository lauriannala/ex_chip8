defmodule ExChip8.StateCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias ExChip8.StateServer
    end
  end

  setup _ do
    start_supervised(ExChip8.StateServer)

    :ok
  end
end
