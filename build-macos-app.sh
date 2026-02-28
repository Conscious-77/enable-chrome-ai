#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script only supports macOS." >&2
  exit 1
fi

if ! command -v osacompile >/dev/null 2>&1; then
  echo "osacompile not found. Please install Xcode Command Line Tools." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCH_SH=""

if [[ -x "$SCRIPT_DIR/Chrome with Gemini.sh" ]]; then
  LAUNCH_SH="$SCRIPT_DIR/Chrome with Gemini.sh"
elif [[ -x "$SCRIPT_DIR/start.sh" ]]; then
  LAUNCH_SH="$SCRIPT_DIR/start.sh"
fi

if [[ -z "$LAUNCH_SH" ]]; then
  echo "No launcher script found. Expected executable 'Chrome with Gemini.sh' or 'start.sh'." >&2
  exit 1
fi

APP_NAME="Enable Chrome AI.app"
OUT_DIR="${1:-$HOME/Applications}"
APP_PATH="$OUT_DIR/$APP_NAME"
TMP_SCPT="$(mktemp /tmp/enable-chrome-ai.XXXXXX.applescript)"
LAUNCH_NAME="$(basename "$LAUNCH_SH")"
SHELL_CMD="$(printf 'cd %q && ./%q' "$SCRIPT_DIR" "$LAUNCH_NAME")"
APPLE_CMD="${SHELL_CMD//\\/\\\\}"
APPLE_CMD="${APPLE_CMD//\"/\\\"}"

mkdir -p "$OUT_DIR"

cat > "$TMP_SCPT" <<EOF
on run
  set cmd to "$APPLE_CMD"
  tell application "Terminal"
    activate
    do script cmd
  end tell
end run
EOF

rm -rf "$APP_PATH"
osacompile -o "$APP_PATH" "$TMP_SCPT"
rm -f "$TMP_SCPT"

echo "App created: $APP_PATH"
echo "Tip: You can pin it to Dock for one-click launch."
