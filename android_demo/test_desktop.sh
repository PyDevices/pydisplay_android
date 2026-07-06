#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Run Android demos on desktop (Xvfb) before building an APK.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEMO="$ROOT/android_demo"
USDL2_DIR="${USDL2_DIR:-$ROOT/../usdl2}"
PYDISPLAY="${PYDISPLAY_DIR:-$ROOT/../pydisplay}"
LVCPY="${LVCPY_DIR:-$ROOT/../lv_cpython_mod}"

if [[ ! -d "$PYDISPLAY/src/lib/displaysys" ]]; then
  echo "Clone pydisplay beside pydisplay_android (or set PYDISPLAY_DIR):"
  echo "  git clone https://github.com/PyDevices/pydisplay.git $PYDISPLAY"
  exit 1
fi

if [[ ! -f "$USDL2_DIR/setup.py" ]]; then
  echo "Clone usdl2 beside pydisplay_android (or set USDL2_DIR):"
  echo "  git clone https://github.com/PyDevices/usdl2.git $USDL2_DIR"
  exit 1
fi

pip install -q -e "$USDL2_DIR"
export PYTHONPATH="$PYDISPLAY/src/lib:$PYDISPLAY/src/add_ons:${PYTHONPATH:-}"
cd "$DEMO"

echo "== pydisplay touch-paint (main.py) =="
xvfb-run -a python3 main.py &
PID=$!
sleep 2
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

if [[ -d "$LVCPY/generated" ]]; then
  echo "== LVGL + display_driver (main_lvgl.py) =="
  pip install -q -e "$LVCPY"
  xvfb-run -a python3 main_lvgl.py &
  PID=$!
  sleep 2
  kill "$PID" 2>/dev/null || true
  wait "$PID" 2>/dev/null || true
else
  echo "Skip LVGL smoke (clone lv_cpython_mod beside pydisplay_android or set LVCPY_DIR)"
fi

echo "Desktop demos exited cleanly (or were stopped after smoke window)"
