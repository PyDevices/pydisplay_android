#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Download display_driver.py and lv_utils.py from the pydisplay GitHub repo.
#
# Usage:
#   ./scripts/fetch_pydisplay_addons.sh DEST_DIR
#
# Environment:
#   PYDISPLAY_GITHUB_REPO   GitHub repo (default: PyDevices/pydisplay)
#   PYDISPLAY_GITHUB_REF    Branch, tag, or commit (default: main)
set -euo pipefail

DEST="${1:-}"
if [[ -z "$DEST" ]]; then
  echo "Usage: $0 DEST_DIR" >&2
  exit 1
fi

REPO="${PYDISPLAY_GITHUB_REPO:-PyDevices/pydisplay}"
REF="${PYDISPLAY_GITHUB_REF:-main}"
BASE="https://raw.githubusercontent.com/${REPO}/${REF}/src/add_ons"

mkdir -p "$DEST"

fetch_one() {
  local name=$1
  local url="${BASE}/${name}"
  local dest="${DEST}/${name}"
  echo "==> Fetching ${name} (${REPO}@${REF})"
  curl -fSL "$url" -o "$dest"
  [[ -s "$dest" ]] || {
    echo "Download failed or empty: $url" >&2
    exit 1
  }
}

fetch_one display_driver.py
fetch_one lv_utils.py
