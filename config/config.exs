import Config

width = 64
height = 32
tile_size = 16
monitor_panel_width = 300
config :ex_chip8, :chip8_tile_size, tile_size
config :ex_chip8, :font_size, 32
config :ex_chip8, :chip8_width, width
config :ex_chip8, :chip8_height, height
config :ex_chip8, :sleep_wait_period, 5
config :ex_chip8, :chip8_memory_size, 4096
config :ex_chip8, :chip8_total_data_registers, 16
config :ex_chip8, :chip8_total_stack_depth, 16
config :ex_chip8, :chip8_total_keys, 16
config :ex_chip8, :chip8_program_load_address, 0x200
config :ex_chip8, :chip8_program_load_address, 0x200
config :ex_chip8, :chip8_default_sprite_height, 5
config :ex_chip8, :monitor_panel_width, monitor_panel_width

config :ex_chip8, :viewport, %{
  name: :main_viewport,
  size: {width * tile_size + monitor_panel_width, height * tile_size},
  default_scene: {ExChip8.Scenes.Game, 0x0000},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "ex_chip8"]
    }
  ]
}

config :ex_chip8, :chip8_default_character_set, [
  0xF0,
  0x90,
  0x90,
  0x90,
  0xF0,
  0x20,
  0x60,
  0x20,
  0x20,
  0x70,
  0xF0,
  0x10,
  0xF0,
  0x80,
  0xF0,
  0xF0,
  0x10,
  0xF0,
  0x10,
  0xF0,
  0x90,
  0x90,
  0xF0,
  0x10,
  0x10,
  0xF0,
  0x80,
  0xF0,
  0x10,
  0xF0,
  0xF0,
  0x80,
  0xF0,
  0x90,
  0xF0,
  0xF0,
  0x10,
  0x20,
  0x40,
  0x40,
  0xF0,
  0x90,
  0xF0,
  0x90,
  0xF0,
  0xF0,
  0x90,
  0xF0,
  0x10,
  0xF0,
  0xF0,
  0x90,
  0xF0,
  0x90,
  0x90,
  0xE0,
  0x90,
  0xE0,
  0x90,
  0xE0,
  0xF0,
  0x80,
  0x80,
  0x80,
  0xF0,
  0xE0,
  0x90,
  0x90,
  0x90,
  0xE0,
  0xF0,
  0x80,
  0xF0,
  0x80,
  0xF0,
  0xF0,
  0x80,
  0xF0,
  0x80,
  0x80
]

import_config "#{config_env()}.exs"
