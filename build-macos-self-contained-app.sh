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
if ! command -v iconutil >/dev/null 2>&1; then
  echo "iconutil not found. Please install Xcode Command Line Tools." >&2
  exit 1
fi
if ! command -v sips >/dev/null 2>&1; then
  echo "sips not found (required for icon conversion)." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICON_PNG="${ICON_PNG:-$SCRIPT_DIR/Gemini_Generated_Image_wnykobwnykobwnyk.png}"
if [[ ! -f "$ICON_PNG" ]]; then
  echo "Icon png not found: $ICON_PNG" >&2
  exit 1
fi

PYTHON_BIN="$SCRIPT_DIR/.venv/bin/python"
if [[ ! -x "$PYTHON_BIN" ]]; then
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="$(command -v python3)"
  else
    echo "No Python runtime found (.venv/bin/python or python3)." >&2
    exit 1
  fi
fi

echo "Using Python: $PYTHON_BIN"

if ! "$PYTHON_BIN" -m PyInstaller --version >/dev/null 2>&1; then
  echo "Installing PyInstaller..."
  "$PYTHON_BIN" -m pip install pyinstaller
fi

APP_NAME="Enable Chrome AI.app"
OUT_DIR="${1:-$HOME/Applications}"
APP_PATH="$OUT_DIR/$APP_NAME"

BUILD_ROOT="$SCRIPT_DIR/dist-self-contained"
BIN_DIST="$BUILD_ROOT/bin"
BIN_PATH="$BIN_DIST/enable-chrome-ai-bin"
WORK_PATH="$BUILD_ROOT/build"
SPEC_PATH="$BUILD_ROOT/spec"

mkdir -p "$OUT_DIR" "$BIN_DIST" "$WORK_PATH" "$SPEC_PATH"

echo "Building self-contained binary..."
"$PYTHON_BIN" -m PyInstaller \
  --noconfirm \
  --clean \
  --onefile \
  --name enable-chrome-ai-bin \
  --distpath "$BIN_DIST" \
  --workpath "$WORK_PATH" \
  --specpath "$SPEC_PATH" \
  "$SCRIPT_DIR/main.py"

if [[ ! -x "$BIN_PATH" ]]; then
  echo "Build failed: binary not found at $BIN_PATH" >&2
  exit 1
fi

TMP_SCPT="$(mktemp /tmp/enable-chrome-ai-self-contained.XXXXXX.applescript)"
cat > "$TMP_SCPT" <<'EOF'
on run
  set appPath to POSIX path of (path to me)
  set binPath to appPath & "Contents/Resources/enable-chrome-ai-bin"
  set closeChoice to button returned of (display dialog "运行前是否关闭 Chrome？（推荐）" buttons {"不关闭", "关闭"} default button "关闭")
  set closeArg to "yes"
  if closeChoice is "不关闭" then
    set closeArg to "no"
  end if

  set cmd to quoted form of binPath & " --close-chrome " & closeArg
  tell application "Terminal"
    do script cmd
    set runWindowId to id of front window
    activate
    try
      repeat while busy of selected tab of window id runWindowId
        delay 0.2
      end repeat
    on error
      -- Ignore if user closed the window/tab manually.
    end try
    delay 0.2
    try
      if exists window id runWindowId then
        close window id runWindowId
      end if
    end try
  end tell
end run
EOF

echo "Packaging .app..."
rm -rf "$APP_PATH"
osacompile -o "$APP_PATH" "$TMP_SCPT"
rm -f "$TMP_SCPT"

mkdir -p "$APP_PATH/Contents/Resources"
cp "$BIN_PATH" "$APP_PATH/Contents/Resources/enable-chrome-ai-bin"
chmod +x "$APP_PATH/Contents/Resources/enable-chrome-ai-bin"

ICONSET_DIR="$BUILD_ROOT/icon.iconset"
ICNS_PATH="$BUILD_ROOT/app.icns"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

sips -z 16 16     "$ICON_PNG" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips -z 32 32     "$ICON_PNG" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -z 32 32     "$ICON_PNG" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -z 64 64     "$ICON_PNG" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -z 128 128   "$ICON_PNG" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -z 256 256   "$ICON_PNG" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -z 256 256   "$ICON_PNG" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -z 512 512   "$ICON_PNG" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -z 512 512   "$ICON_PNG" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
sips -z 1024 1024 "$ICON_PNG" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null

iconutil -c icns "$ICONSET_DIR" -o "$ICNS_PATH"
cp "$ICNS_PATH" "$APP_PATH/Contents/Resources/applet.icns"

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$APP_PATH" >/dev/null 2>&1 || true
fi

echo "Self-contained app created: $APP_PATH"
echo "This app no longer depends on the project directory."
