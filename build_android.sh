#!/usr/bin/env bash
# Build the p4a_app Android APK from this repo.
#
# Usage:
#   ./build_android.sh [extra buildozer args after "android debug"...]
#
# Cache policy (important):
#   Never wipes p4a_app/.buildozer or ~/.buildozer between runs. Incremental
#   rebuilds reuse hostpython, python3, sdl2, and recipe builds. This script
#   refuses buildozer clean/distclean unless ALLOW_CLEAN=1.
#
# Environment:
#   VENV_DIR            Host build venv (default: $SCRIPT_DIR/.venv)
#   REQUIREMENTS        Host pip requirements (default: $SCRIPT_DIR/requirements.txt)
#   ANDROID_HOME        Android SDK (default: ~/.buildozer/android/platform/android-sdk)
#   ANDROID_NDK_HOME    Android NDK (auto-detected under $ANDROID_HOME/ndk when unset)
#   JAVA_HOME           JDK for Android tooling (auto-detected from java on PATH when unset)
#   FETCH_LVGL_ADDONS   Set to 1 to fetch display_driver.py / lv_utils.py (LVGL apps)
#   ALLOW_CLEAN         Set to 1 to permit clean/distclean args (default: refuse)
#
# Runtime deps are installed from TestPyPI via p4a PyProjectRecipe wrappers in p4a_recipes/.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
VENV_DIR="${VENV_DIR:-$SCRIPT_DIR/.venv}"
REQUIREMENTS="${REQUIREMENTS:-$SCRIPT_DIR/requirements.txt}"
APP_DIR="$SCRIPT_DIR/p4a_app"
TESTPYPI_INDEX="${TESTPYPI_INDEX:-https://test.pypi.org/simple/}"

PYTHON="$VENV_DIR/bin/python3"
PIP="$VENV_DIR/bin/pip"
BUILDOZER="$VENV_DIR/bin/buildozer"

usage() {
    sed -n '2,22p' "$0" | sed 's/^# \?//'
    exit "${1:-0}"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage 0
fi

refuse_cache_wipe_args() {
    # Do not forward buildozer targets that wipe p4a build trees.
    local a
    for a in "$@"; do
        case "$a" in
            clean|distclean|clean_builds|clean_dists|clean_download_cache|clean_all)
                if [[ "${ALLOW_CLEAN:-0}" != "1" ]]; then
                    echo "Refusing to run buildozer '$a' (would wipe Android build cache)." >&2
                    echo "Re-run with ALLOW_CLEAN=1 only if you intentionally want a cold rebuild." >&2
                    exit 2
                fi
                ;;
        esac
    done
}

refuse_cache_wipe_args "$@"

require_dir() {
    local path=$1
    local label=$2
    [[ -d "$path" ]] || {
        echo "Missing $label: $path" >&2
        exit 1
    }
}

require_file() {
    local path=$1
    local label=$2
    [[ -f "$path" ]] || {
        echo "Missing $label: $path" >&2
        exit 1
    }
}

ensure_build_venv() {
    require_file "$REQUIREMENTS" "requirements.txt"
    if [[ ! -x "$PYTHON" ]]; then
        echo "==> Creating build venv at $VENV_DIR"
        python3 -m venv "$VENV_DIR"
    fi
    echo "==> Installing Android build Python deps in $VENV_DIR"
    "$PIP" install -q -U pip setuptools wheel
    "$PIP" install -q -r "$REQUIREMENTS"
    [[ -x "$BUILDOZER" ]] || {
        echo "buildozer not found in $VENV_DIR after pip install" >&2
        exit 1
    }
}

setup_android_env() {
    export BUILDOZER_ANDROID_HOME="${BUILDOZER_ANDROID_HOME:-$HOME/.buildozer/android}"
    export ANDROID_HOME="${ANDROID_HOME:-$BUILDOZER_ANDROID_HOME/platform/android-sdk}"
    export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"

    if [[ -z "${ANDROID_NDK_HOME:-}" && -d "$ANDROID_HOME/ndk" ]]; then
        local ndk
        ndk=$(find "$ANDROID_HOME/ndk" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -V | tail -1)
        if [[ -n "$ndk" ]]; then
            export ANDROID_NDK_HOME="$ndk"
        fi
    fi
    # buildozer layout often keeps the NDK beside the SDK
    if [[ -z "${ANDROID_NDK_HOME:-}" ]]; then
        local ndk
        ndk=$(find "$BUILDOZER_ANDROID_HOME/platform" -maxdepth 1 -type d -name 'android-ndk-*' 2>/dev/null | sort -V | tail -1)
        if [[ -n "$ndk" ]]; then
            export ANDROID_NDK_HOME="$ndk"
        fi
    fi

    if [[ -z "${JAVA_HOME:-}" ]] && command -v java >/dev/null 2>&1; then
        JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")
        export JAVA_HOME
    fi

    export VIRTUAL_ENV="$VENV_DIR"
    export PATH="$VENV_DIR/bin:$PATH"
}

ensure_build_venv
setup_android_env

require_dir "$APP_DIR" "p4a_app"
require_dir "$SCRIPT_DIR/p4a_recipes" "p4a_recipes"
require_file "$APP_DIR/main.py" "p4a_app/main.py"
require_file "$APP_DIR/paint.py" "p4a_app/paint.py"

if [[ "${FETCH_LVGL_ADDONS:-0}" == "1" ]]; then
    echo "==> Fetching display_driver.py and lv_utils.py from pydisplay on GitHub"
    "$SCRIPT_DIR/scripts/fetch_pydisplay_addons.sh" "$APP_DIR"
fi

echo "==> Building Android APK in $APP_DIR"
echo "    venv=$VENV_DIR"
echo "    TestPyPI=$TESTPYPI_INDEX"
echo "    ANDROID_HOME=$ANDROID_HOME"
if [[ -n "${ANDROID_NDK_HOME:-}" ]]; then
    echo "    ANDROID_NDK_HOME=$ANDROID_NDK_HOME"
else
    echo "    ANDROID_NDK_HOME=(unset — buildozer may download NDK on first run)"
fi
if [[ -n "${JAVA_HOME:-}" ]]; then
    echo "    JAVA_HOME=$JAVA_HOME"
fi
if [[ -d "$APP_DIR/.buildozer" ]]; then
    echo "    cache=$APP_DIR/.buildozer (reusing; not cleared)"
else
    echo "    cache=$APP_DIR/.buildozer (first build — will be created)"
fi

cd "$APP_DIR"
# Always "android debug" — never "android clean". Extra args are flags only.
"$BUILDOZER" android debug "$@"

echo "==> APK output:"
ls -1 "$APP_DIR"/bin/*.apk
