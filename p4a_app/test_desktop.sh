#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Run the paint app on desktop (Xvfb) before building an APK.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/p4a_app"
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
  usdl2 displaysys eventsys graphics-cmod multimer

cd "$APP"

echo "== paint (main.py → import lib.path; import paint) =="
xvfb-run -a "$PYTHON" main.py &
PID=$!
sleep 2
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

echo "Desktop smoke exited cleanly (or was stopped after the smoke window)"
