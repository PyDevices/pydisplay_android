#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Build the Android demo APK (requires Android SDK/NDK + buildozer).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEMO="$ROOT/android_demo"
VENV_DIR="${VENV_DIR:-$ROOT/.venv}"

PYTHON="$VENV_DIR/bin/python3"
PIP="$VENV_DIR/bin/pip"
BUILDOZER="$VENV_DIR/bin/buildozer"

if [[ ! -x "$BUILDOZER" ]]; then
  echo "==> Creating build venv at $VENV_DIR"
  python3 -m venv "$VENV_DIR"
  "$PIP" install -q -U pip setuptools wheel
  "$PIP" install -q buildozer Cython
fi

"$ROOT/scripts/fetch_pydisplay_addons.sh" "$DEMO"
"$ROOT/scripts/install_apk_main.sh" "$DEMO"

export BUILDOZER_ANDROID_HOME="${BUILDOZER_ANDROID_HOME:-$HOME/.buildozer/android}"
export ANDROID_HOME="${ANDROID_HOME:-$BUILDOZER_ANDROID_HOME/platform/android-sdk}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
export PATH="$VENV_DIR/bin:$PATH"

cd "$DEMO"
"$BUILDOZER" android debug "$@"
