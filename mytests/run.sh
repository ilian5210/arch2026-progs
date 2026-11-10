#!/bin/sh
# Use the same GCC release as the course CI, and Homebrew Bash for its hooks.
set -eu
export PATH="$HOME/.local/share/ca2026-tools/xpack-riscv-none-elf-gcc-15.2.0-1/bin:$HOME/.local/share/ca2026-tools/python-venv/bin:/opt/homebrew/bin:$HOME/.local/bin:$PATH"
cd "$(dirname "$0")/.."
exec "$@"
