![Erlang](https://img.shields.io/badge/Erlang-white.svg?style=for-the-badge&logo=erlang&logoColor=a90533)
![Elixir](https://img.shields.io/badge/elixir-%234B275F.svg?style=for-the-badge&logo=elixir&logoColor=white)

[![Elixir CI](https://github.com/lauriannala/ex_chip8/actions/workflows/elixir.yml/badge.svg)](https://github.com/lauriannala/ex_chip8/actions/workflows/elixir.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

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
