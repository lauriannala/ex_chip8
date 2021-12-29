defmodule ExChip8.ScreenTest do
  use ExChip8.StateCase

  alias ExChip8.Screen
  alias ExChip8.Screen

  @chip8_memory_size Application.get_env(:ex_chip8, :chip8_memory_size)
  @default_character_set Application.get_env(:ex_chip8, :chip8_default_character_set)

  describe "Initialized screen" do
    setup [:initialize]

    test "screen_is_set?/3 return correct status", %{screen: screen} do
      assert Screen.screen_is_set?(screen, 0, 0) == false
      assert Screen.screen_is_set?(screen, 63, 31) == false
    end

    test "screen_is_set?/3 raises when out of bounds", %{screen: screen} do
      assert_raise MatchError, fn ->
        Screen.screen_is_set?(screen, 64, 0)
      end

      assert_raise MatchError, fn ->
        Screen.screen_is_set?(screen, 0, 32)
      end
    end

    test "screen_set/3 updates pixel correctly", %{screen: screen} do
      updated_screen = Screen.screen_set(screen, 10, 15) |> Screen.update()

      row = Map.get(updated_screen.pixels, 15)
      assert Map.get(row, 10) == true

      assert Enum.filter(row, fn {_index, val} -> val == false end)
             |> length() == 63
    end
  end

  describe "Initialized screen with memory" do
    setup [:initialize_with_memory]

    test "screen_draw_sprite_changeset/1 sets changes correctly", %{screen: screen} do
      result =
        Screen.screen_draw_sprite_changeset(%{
          screen: screen,
          x: 32,
          y: 30,
          memory: nil,
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

    test "screen_draw_sprite_changeset/1 sets collision correctly", %{screen: screen} do
      screen_has_pixels =
        screen
        |> Screen.screen_set(0, 0)
        |> Screen.screen_set(1, 0)
        |> Screen.update()

      result =
        Screen.screen_draw_sprite_changeset(%{
          screen: screen_has_pixels,
          x: 0,
          y: 0,
          memory: nil,
          sprite_index: 0x00,
          num: 1
        })

      assert [
               update: %{collision: true, pixel: false, x: 0, y: 0},
               update: %{collision: true, pixel: false, x: 1, y: 0},
               update: %{collision: false, pixel: true, x: 2, y: 0},
               update: %{collision: false, pixel: true, x: 3, y: 0}
             ] = result
    end

    test "screen_draw_sprite/1 applies changesets to state", %{screen: screen} do
      %{
        collision: collision,
        screen: screen
      } =
        Screen.screen_draw_sprite(%{
          screen: screen,
          x: 32,
          y: 30,
          memory: nil,
          sprite_index: 0x00,
          num: 1
        })

      assert collision == false
      assert Screen.screen_is_set?(screen, 32, 30) == true
      assert Screen.screen_is_set?(screen, 33, 30) == true
      assert Screen.screen_is_set?(screen, 34, 30) == true
      assert Screen.screen_is_set?(screen, 35, 30) == true
    end

    test "screen_draw_sprite/1 applies changesets to state with collision", %{screen: screen} do
      screen
      |> Screen.screen_set(0, 0)
      |> Screen.screen_set(1, 0)
      |> Screen.update()

      %{
        collision: collision
      } =
        Screen.screen_draw_sprite(%{
          x: 0,
          y: 0,
          memory: nil,
          sprite_index: 0x00,
          num: 1
        })

      screen = Screen.get_screen()

      assert true = collision
      assert Screen.screen_is_set?(screen, 0, 0) == false
      assert Screen.screen_is_set?(screen, 1, 0) == false
      assert Screen.screen_is_set?(screen, 2, 0) == true
      assert Screen.screen_is_set?(screen, 3, 0) == true
    end
  end

  defp initialize(_) do
    Screen.init_state(
      sleep_wait_period: 5,
      chip8_height: 32,
      chip8_width: 64
    )

    %{screen: Screen.get_screen()}
  end

  defp initialize_with_memory(_) do
    initialize(%{})

    old_state = {nil, nil, nil, nil, nil}

    ExChip8.Memory.init(old_state, @chip8_memory_size)

    {:ok, old_state, "filename"}
    |> ExChip8.init(@default_character_set)

    %{screen: Screen.get_screen()}
  end
end
