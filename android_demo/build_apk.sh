#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Build the Android demo APK (requires Android SDK/NDK + buildozer).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
USDL2_DIR="${USDL2_DIR:-$ROOT/../usdl2}"
cd "$ROOT/android_demo"

if ! command -v buildozer >/dev/null 2>&1; then
  echo "Install buildozer: pip install buildozer"
  echo "Set ANDROID_HOME / ANDROID_NDK_HOME per python-for-android docs."
  exit 1
fi

if [[ ! -f "$USDL2_DIR/p4a_recipes/usdl2/__init__.py" ]]; then
  echo "Clone usdl2 beside pydisplay_android (or set USDL2_DIR):"
  echo "  git clone https://github.com/PyDevices/usdl2.git $USDL2_DIR"
  exit 1
fi

# Link usdl2's p4a recipe into this repo's recipe dir for buildozer.
ln -sfn "$USDL2_DIR/p4a_recipes/usdl2" "$ROOT/p4a_recipes/usdl2"

export P4A_usdl2_DIR="$USDL2_DIR"
if [[ -d "$ROOT/../pydisplay" ]]; then
  export P4A_pydisplay_DIR="$ROOT/../pydisplay"
fi
if [[ -d "$ROOT/../lv_cpython_mod" ]]; then
  export P4A_lvgl_cpython_DIR="$ROOT/../lv_cpython_mod"
fi

buildozer android debug "$@"
