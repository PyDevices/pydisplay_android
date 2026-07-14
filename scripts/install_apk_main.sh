#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Optional helper: rewrite main.py to import an alternate module (e.g. for LVGL).
# Default paint entry is the committed p4a_app/main.py (`import lib.path` / `import paint`).
#
# Usage:
#   ./scripts/install_apk_main.sh DEST_DIR
#
# Environment:
#   APK_ENTRY   Module name to import after lib.path (default: paint). Set to "skip" to no-op.
set -euo pipefail

DEST="${1:-}"
if [[ -z "$DEST" ]]; then
  echo "Usage: $0 DEST_DIR" >&2
  exit 1
fi

ENTRY="${APK_ENTRY:-paint}"
if [[ "$ENTRY" == "skip" ]]; then
  exit 0
fi

# Strip optional .py suffix
ENTRY="${ENTRY%.py}"

if [[ ! -f "$DEST/${ENTRY}.py" ]]; then
  echo "APK entry module not found: $DEST/${ENTRY}.py" >&2
  exit 1
fi

cat > "$DEST/main.py" <<PY
# SPDX-License-Identifier: MIT
# p4a SDL2 bootstrap requires a file named main.py (rewritten by install_apk_main.sh).
import lib.path  # noqa: F401
import ${ENTRY}
PY

echo "==> Wrote $DEST/main.py -> import lib.path; import ${ENTRY}"
