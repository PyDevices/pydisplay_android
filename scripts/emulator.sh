#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Install the pydisplay demo APK on a running Android emulator and launch it.
#
# Usage:
#   ./scripts/emulator.sh [APK_PATH]
#
# Environment:
#   ANDROID_HOME          Android SDK (default: ~/.buildozer/android/platform/android-sdk)
#   PYDISPLAY_ANDROID_DIR Repo root (auto-detected)
#   ADB                   Override adb executable (auto-detected on WSL vs Linux)
#   PACKAGE_ID            App id (default: org.pydevices.pydisplaydemo)
#   ACTIVITY              Main activity (default: org.kivy.android.PythonActivity)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEMO="$ROOT/android_demo"

PACKAGE_ID="${PACKAGE_ID:-org.pydevices.pydisplaydemo}"
ACTIVITY="${ACTIVITY:-org.kivy.android.PythonActivity}"
COMPONENT="${PACKAGE_ID}/${ACTIVITY}"

ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/.buildozer/android/platform/android-sdk}}"

is_wsl() {
  if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    return 0
  fi
  if [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
    return 0
  fi
  return 1
}

usage() {
  sed -n '2,13p' "$0" | sed 's/^# \?//'
  exit "${1:-0}"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage 0
fi

print_missing_avd_wsl() {
  cat <<'EOF'

No Android emulator is connected to adb.

You appear to be on WSL. The Android emulator normally runs on Windows, not inside
WSL. Set it up like this:

  1. Install Android Studio on Windows (not inside WSL):
       https://developer.android.com/studio

  2. Open Android Studio → More Actions → Virtual Device Manager
     (or Tools → Device Manager).

  3. Create Device → pick a phone (e.g. Pixel 6) → Next.

  4. Select a system image with API 31 or newer and arm64-v8a support, e.g.:
       Android 13 (API 33) · arm64-v8a
     Download the image if needed → Next → Finish.

  5. Click the Play (▶) button next to the AVD to start the emulator on Windows.
     Wait until the home screen is fully up.

  6. From WSL, confirm Windows adb sees the emulator:
       adb.exe devices
     You should see a line like: emulator-5554   device

  7. Re-run this script:
       ./scripts/emulator.sh

If adb.exe is not found in WSL, add Windows platform-tools to your PATH, e.g.:
  export PATH="$PATH:/mnt/c/Users/$USER/AppData/Local/Android/Sdk/platform-tools"

Or set ADB explicitly:
  ADB='/mnt/c/Users/YOUR_USER/AppData/Local/Android/Sdk/platform-tools/adb.exe' ./scripts/emulator.sh

Build the APK first if you have not already:
  ./build_android.sh
EOF
}

print_missing_avd_unix() {
  cat <<EOF

No Android emulator is connected to adb.

Set up an AVD on Linux/macOS like this:

  1. Install Android Studio or the Android SDK command-line tools:
       https://developer.android.com/studio#command-tools

  2. Point ANDROID_HOME at your SDK (buildozer default shown):
       export ANDROID_HOME="${HOME}/.buildozer/android/platform/android-sdk"
       export PATH="\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/emulator:\$PATH"

  3. Install emulator pieces (adjust API level if needed):
       sdkmanager "platform-tools" "emulator" \\
         "platforms;android-31" \\
         "system-images;android-31;google_apis;arm64-v8a"

  4. Create an AVD (pick any unused name):
       avdmanager create avd -n pydisplay_api31 -k \\
         "system-images;android-31;google_apis;arm64-v8a" -d pixel_6

  5. Start the emulator:
       emulator -avd pydisplay_api31 &

  6. Wait for boot, then confirm:
       adb devices

  7. Re-run this script:
       ./scripts/emulator.sh

Build the APK first if you have not already:
  ./build_android.sh
EOF
}

pick_adb() {
  if [[ -n "${ADB:-}" ]]; then
    echo "$ADB"
    return 0
  fi

  if is_wsl && command -v adb.exe >/dev/null 2>&1; then
    echo "adb.exe"
    return 0
  fi

  local candidates=(
    "$ANDROID_HOME/platform-tools/adb"
    "${ANDROID_SDK_ROOT:-}/platform-tools/adb"
    "$HOME/Android/Sdk/platform-tools/adb"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done

  if command -v adb >/dev/null 2>&1; then
    echo "adb"
    return 0
  fi

  return 1
}

find_apk() {
  local arg="${1:-}"
  if [[ -n "$arg" ]]; then
    if [[ -f "$arg" ]]; then
      echo "$(cd "$(dirname "$arg")" && pwd)/$(basename "$arg")"
      return 0
    fi
    echo "APK not found: $arg" >&2
    return 1
  fi

  local -a candidates=()
  local dir apk
  for dir in "$DEMO/bin"; do
    [[ -d "$dir" ]] || continue
    shopt -s nullglob
    for apk in "$dir"/*.apk; do
      candidates+=("$apk")
    done
    shopt -u nullglob
  done

  if [[ ${#candidates[@]} -eq 0 ]]; then
    echo "No APK found. Build one first:" >&2
    echo "  cd $ROOT && ./build_android.sh" >&2
    return 1
  fi

  # Prefer newest debug APK by modification time.
  local newest="${candidates[0]}"
  local path
  for path in "${candidates[@]}"; do
    if [[ "$path" -nt "$newest" ]]; then
      newest="$path"
    fi
  done
  echo "$(cd "$(dirname "$newest")" && pwd)/$(basename "$newest")"
}

adb_cmd() {
  "$ADB_BIN" "$@"
}

adb_install_arg() {
  local apk=$1
  if is_wsl && [[ "$ADB_BIN" == *adb.exe* || "$ADB_BIN" == adb.exe ]]; then
    wslpath -w "$apk"
  else
    echo "$apk"
  fi
}

list_devices() {
  adb_cmd devices | awk 'NR>1 && $2=="device" { print $1 }'
}

ADB_BIN="$(pick_adb)" || {
  echo "adb not found." >&2
  if is_wsl; then
    print_missing_avd_wsl
  else
    print_missing_avd_unix
  fi
  exit 1
}

APK_PATH="$(find_apk "${1:-}")"

if is_wsl; then
  echo "==> WSL detected — using adb: $ADB_BIN"
else
  echo "==> Linux/macOS — using adb: $ADB_BIN"
fi
echo "==> APK: $APK_PATH"

mapfile -t DEVICES < <(list_devices)
if [[ ${#DEVICES[@]} -eq 0 ]]; then
  echo "==> No emulator/device connected." >&2
  if is_wsl; then
    print_missing_avd_wsl
  else
    print_missing_avd_unix
  fi
  exit 1
fi

if [[ ${#DEVICES[@]} -gt 1 ]]; then
  echo "==> Multiple devices connected; using ${DEVICES[0]}"
  export ANDROID_SERIAL="${DEVICES[0]}"
fi

INSTALL_PATH="$(adb_install_arg "$APK_PATH")"
echo "==> Installing on ${ANDROID_SERIAL:-default device}"
adb_cmd install -r "$INSTALL_PATH"

echo "==> Launching $COMPONENT"
adb_cmd shell am start -n "$COMPONENT"

echo "==> Demo launched on ${ANDROID_SERIAL:-default device}."
echo "    View logs: $ADB_BIN logcat -s python:V SDL:V ActivityManager:I"
