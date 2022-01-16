import Config

if config_env() == :prod do
  config :ex_chip8, :filename, System.fetch_env!("CHIP8_FILENAME")
end
