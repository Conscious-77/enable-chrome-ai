#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ -x ".venv/bin/python" ]; then
  exec ".venv/bin/python" main.py
fi

if command -v uv >/dev/null 2>&1; then
  if [ ! -d ".venv" ]; then
    echo "No .venv found. Running uv sync first..."
    uv sync
  fi
  exec uv run main.py
fi

if command -v python3 >/dev/null 2>&1; then
  exec python3 main.py
fi

echo "No usable Python runtime found. Install uv or create .venv first." >&2
exit 1
