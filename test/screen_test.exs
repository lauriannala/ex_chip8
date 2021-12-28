defmodule ExChip8.ScreenTest do
  use ExChip8.StateCase

  alias ExChip8.Screen
  alias ExChip8.{Screen, Stack, Keyboard}

  @chip8_memory_size Application.get_env(:ex_chip8, :chip8_memory_size)
  @default_character_set Application.get_env(:ex_chip8, :chip8_default_character_set)

  describe "Unitialized screen" do
    test "init_state/2 initializes correctly" do
      {screen, _, _, _, _} =
        Screen.init_state(
          {%Screen{}, nil, nil, %Stack{}, %Keyboard{}},
          sleep_wait_period: 5,
          chip8_height: 32,
          chip8_width: 64
        )

      assert screen.sleep_wait_period == 5
      assert screen.chip8_height == 32
      assert screen.chip8_width == 64

      assert Enum.at(screen.pixels, 0) ==
               Enum.map(1..64, fn _ -> false end)

      assert Enum.at(screen.pixels, 31) ==
               Enum.map(1..64, fn _ -> false end)
    end
  end

  describe "Initialized screen" do
    setup [:initialize]

    test "screen_is_set?/3 return correct status", %{state: {screen, _, _, _, _}} do
      assert Screen.screen_is_set?(screen, 0, 0) == false
      assert Screen.screen_is_set?(screen, 63, 31) == false
    end

    test "screen_is_set?/3 raises when out of bounds", %{state: {screen, _, _, _, _}} do
      assert_raise RuntimeError, fn ->
        Screen.screen_is_set?(screen, 64, 0)
      end

      assert_raise RuntimeError, fn ->
        Screen.screen_is_set?(screen, 0, 32)
      end
    end

    test "screen_set/3 updates pixel correctly", %{state: {screen, _, _, _, _}} do
      updated_screen = Screen.screen_set(screen, 10, 15)

      row = Enum.at(updated_screen.pixels, 15)
      assert Enum.at(row, 10) == true

      assert Enum.filter(row, fn val -> val == false end)
             |> length() == 63
    end
  end

  describe "Initialized screen with memory" do
    setup [:initialize_with_memory]

    test "screen_draw_sprite_changeset/1 sets changes correctly", %{
      state: {screen, memory, _, _, _}
    } do
      result =
        Screen.screen_draw_sprite_changeset(%{
          screen: screen,
          x: 32,
          y: 30,
          memory: memory,
          sprite_index: 0x00,
          num: 1
        })

      assert result == [
               update: %{collision: false, pixel: true, x: 32, y: 30},
               update: %{collision: false, pixel: true, x: 33, y: 30},
               update: %{collision: false, pixel: true, x: 34, y: 30},
               update: %{collision: false, pixel: true, x: 35, y: 30}
             ]
    end

    test "screen_draw_sprite_changeset/1 sets collision correctly", %{
      state: {screen, memory, _, _, _}
    } do
      screen_has_pixels =
        screen
        |> Screen.screen_set(0, 0)
        |> Screen.screen_set(1, 0)

      result =
        Screen.screen_draw_sprite_changeset(%{
          screen: screen_has_pixels,
          x: 0,
          y: 0,
          memory: memory,
          sprite_index: 0x00,
          num: 1
        })

      assert result == [
               update: %{collision: true, pixel: false, x: 0, y: 0},
               update: %{collision: true, pixel: false, x: 1, y: 0},
               update: %{collision: false, pixel: true, x: 2, y: 0},
               update: %{collision: false, pixel: true, x: 3, y: 0}
             ]
    end

    test "screen_draw_sprite/1 applies changesets to state", %{state: {screen, memory, _, _, _}} do
      %{
        collision: collision,
        screen: screen
      } =
        Screen.screen_draw_sprite(%{
          screen: screen,
          x: 32,
          y: 30,
          memory: memory,
          sprite_index: 0x00,
          num: 1
        })

      assert collision == false
      assert Screen.screen_is_set?(screen, 32, 30) == true
      assert Screen.screen_is_set?(screen, 33, 30) == true
      assert Screen.screen_is_set?(screen, 34, 30) == true
      assert Screen.screen_is_set?(screen, 35, 30) == true
    end

    test "screen_draw_sprite/1 applies changesets to state with collision", %{
      state: {screen, memory, _, _, _}
    } do
      screen_has_pixels =
        screen
        |> Screen.screen_set(0, 0)
        |> Screen.screen_set(1, 0)

      %{
        collision: collision,
        screen: screen
      } =
        Screen.screen_draw_sprite(%{
          screen: screen_has_pixels,
          x: 0,
          y: 0,
          memory: memory,
          sprite_index: 0x00,
          num: 1
        })

      assert collision == true
      assert Screen.screen_is_set?(screen, 0, 0) == false
      assert Screen.screen_is_set?(screen, 1, 0) == false
      assert Screen.screen_is_set?(screen, 2, 0) == true
      assert Screen.screen_is_set?(screen, 3, 0) == true
    end
  end

  defp initialize(_) do
    state =
      Screen.init_state(
        {%Screen{}, nil, nil, %Stack{}, %Keyboard{}},
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

    {:ok, state, _} =
      {:ok, state, "filename"}
      |> ExChip8.init(@default_character_set)

    %{state: state}
  end
end
