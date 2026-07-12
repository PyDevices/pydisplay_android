#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Thin wrapper — prefer ../build_android.sh from the repo root.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "$ROOT/build_android.sh" "$@"
