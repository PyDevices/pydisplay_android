#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Thin wrapper — prefer ../build_android.sh from the repo root.
#
# Does not clear p4a_app/.buildozer or ~/.buildozer; see build_android.sh
# (refuses clean/distclean unless ALLOW_CLEAN=1).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "$ROOT/build_android.sh" "$@"
