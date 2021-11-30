use Mix.Config

config :ex_chip8, :chip8_width, 64
config :ex_chip8, :chip8_height, 32
config :ex_chip8, :sleep_wait_period, 2
# config :ex_chip8, :sleep_wait_period, 1000
config :ex_chip8, :chip8_memory_size, 4096
config :ex_chip8, :chip8_total_data_registers, 16
config :ex_chip8, :chip8_total_stack_depth, 16
config :ex_chip8, :chip8_total_keys, 16
config :ex_chip8, :chip8_program_load_address, 0x200
config :ex_chip8, :chip8_program_load_address, 0x200
config :ex_chip8, :chip8_default_sprite_height, 5

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
