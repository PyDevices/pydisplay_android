#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Run Android demos on desktop (Xvfb) before building an APK.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEMO="$ROOT/android_demo"
VENV_DIR="${VENV_DIR:-$ROOT/.venv}"
TESTPYPI="https://test.pypi.org/simple/"
PYPI="https://pypi.org/simple/"

PYTHON="$VENV_DIR/bin/python3"
PIP="$VENV_DIR/bin/pip"

if [[ ! -x "$PYTHON" ]]; then
  python3 -m venv "$VENV_DIR"
  "$PIP" install -q -U pip
fi

"$PIP" install -q \
  -i "$TESTPYPI" --extra-index-url "$PYPI" \
  usdl2 displaysys eventsys graphics multimer lvgl-cpython

"$ROOT/scripts/fetch_pydisplay_addons.sh" "$DEMO"

cd "$DEMO"

echo "== pydisplay touch-paint (main.py) =="
xvfb-run -a "$PYTHON" main.py &
PID=$!
sleep 2
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

echo "== LVGL + display_driver (main_lvgl.py) =="
xvfb-run -a "$PYTHON" main_lvgl.py &
PID=$!
sleep 2
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

echo "Desktop demos exited cleanly (or were stopped after smoke window)"
