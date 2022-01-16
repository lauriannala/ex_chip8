![Erlang](https://img.shields.io/badge/Erlang-white.svg?style=for-the-badge&logo=erlang&logoColor=a90533)
![Elixir](https://img.shields.io/badge/elixir-%234B275F.svg?style=for-the-badge&logo=elixir&logoColor=white)

[![Elixir CI](https://github.com/lauriannala/ex_chip8/actions/workflows/elixir.yml/badge.svg)](https://github.com/lauriannala/ex_chip8/actions/workflows/elixir.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# ExChip8

Chip8 emulator written with Elixir using Scenic.

## Requirements

```shell
# Scenic deps installation:
sudo apt-get install pkgconf libglfw3 libglfw3-dev libglew2.1 libglew-dev
```

## Using release binary

```shell
CHIP8_FILENAME="<rom filename>" ./chip8/bin/ex_chip8 start
```

## Development

```shell
# Install deps and compile:
mix deps.get
mix compile

# Run mix dev mix task:
mix game

# Run tests
mix test

```

* Configure used game rom:
```elixir
# config/dev.exs:
config :ex_chip8, :filename, "<rom filename>"
```

## Dialyzer

```shell
# Create plt cache folder.
mkdir -p priv/plts

# Run dialyzer check.
mix dialyzer
```
