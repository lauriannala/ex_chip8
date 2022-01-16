[![Elixir CI](https://github.com/lauriannala/ex_chip8/actions/workflows/elixir.yml/badge.svg)](https://github.com/lauriannala/ex_chip8/actions/workflows/elixir.yml)

# ExChip8

Chip8 emulator written with Elixir using Scenic.

# Running

```bash
Setup your rom game file and configure it to config/config.exs:
config :ex_chip8, :filename, "<your totally awesome rom file>"

mix deps.get
mix game
```

# Dialyzer

```shell
# Create plt cache folder.
mkdir -p priv/plts

# Run dialyzer check.
mix dialyzer
```
