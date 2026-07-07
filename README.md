# pydisplay_android

Android APK integration for [pydisplay](https://github.com/PyDevices/pydisplay): **python-for-android** recipes, a **buildozer** demo, and desktop smoke tests.

On Android there is no MicroPython port; pydisplay runs under **CPython** in a **python-for-android** APK with the **SDL2 bootstrap**. Runtime packages are installed from **[TestPyPI](https://test.pypi.org/)** — not from local git checkouts.

## TestPyPI packages

| PyPI name | Import | Role |
|-----------|--------|------|
| [usdl2](https://test.pypi.org/project/usdl2/) | `usdl2` | CPython ctypes SDL2 FFI |
| [displaysys](https://test.pypi.org/project/displaysys/) | `displaysys` | Display drivers (`SDLDisplay`, …) |
| [eventsys](https://test.pypi.org/project/eventsys/) | `eventsys` | Event broker / input queue |
| [graphics](https://test.pypi.org/project/graphics/) | `graphics` | Drawing helpers |
| [multimer](https://test.pypi.org/project/multimer/) | `multimer` | Timers (`_sdl2` backend on Android) |
| [lvgl-cpython](https://test.pypi.org/project/lvgl-cpython/) | `lvgl` | LVGL native extension (Android wheels: `android_21_arm64_v8a`, …) |

`display_driver.py` and `lv_utils.py` are fetched from [pydisplay on GitHub](https://github.com/PyDevices/pydisplay) at build time (not vendored; not yet on TestPyPI). Override with `PYDISPLAY_GITHUB_REPO` / `PYDISPLAY_GITHUB_REF`.

## Build demo APK

Prerequisites: [Android SDK + NDK](https://python-for-android.readthedocs.io/en/latest/quickstart.html), Ubuntu/WSL build tools (`git`, `zip`, `openjdk-17-jdk`, `autoconf`, …).

From this repo:

```bash
cd pydisplay_android/android_demo
./build_apk.sh
# APK: android_demo/bin/pydisplaydemo-0.4.0-*-debug.apk (name may vary)
adb install -r bin/*.apk
```

`build_apk.sh` creates `.venv/` in the repo root and installs `buildozer`. p4a pulls the PyDevices packages from TestPyPI via `p4a.extra_args` in `buildozer.spec`.

From a **cmods** workspace (also freezes modules from root `manifest.py`):

```bash
cd ~/github/cmods
./build_android.sh
```

## pydisplay + LVGL on Android

| File | Role |
|------|------|
| `p4a_recipes/*/` | Thin `PyProjectRecipe` wrappers — install TestPyPI wheels |
| `android_demo/board_config.py` | SDL display + event broker (landscape, fullscreen on Android) |
| `scripts/fetch_pydisplay_addons.sh` | Downloads `display_driver.py` + `lv_utils.py` from GitHub |
| `scripts/emulator.sh` | Install APK on emulator and launch the demo |
| `scripts/phone.sh` | Install APK on USB phone, launch, and tail debug logcat |
| `android_demo/main_lvgl.py` | LVGL touch grid demo — default APK entry |
| `android_demo/main.py` | Touch-paint demo without LVGL |
| `android_demo/main_usdl2_raw.py` | Raw `usdl2` reference demo (no pydisplay stack) |

`buildozer.spec` requirements:

```
python3,sdl2,usdl2,displaysys,eventsys,graphics,multimer,lvglcpython
```

(`python3` unpinned — p4a currently pairs target and host Python at 3.14.2; do not pin `python3==3.13` or versions diverge.)

On Android, **multimer** selects the **`_sdl2`** backend when `usdl2` is available.

## Desktop smoke test (Xvfb)

Installs runtime packages from TestPyPI into `.venv/`:

```bash
cd pydisplay_android/android_demo
./test_desktop.sh
```

## Run on an emulator

With a debug APK already built and an emulator running:

```bash
./scripts/emulator.sh
# optional: ./scripts/emulator.sh path/to/your.apk
```

On WSL, start the AVD from Android Studio on Windows first; the script uses `adb.exe` when available.

With a USB phone (Developer options → USB debugging):

```bash
./scripts/phone.sh
# install + launch + logcat; use --no-logs to skip log tail
```

## Your own app

Copy `android_demo/board_config.py`. Run `scripts/fetch_pydisplay_addons.sh` (or let `build_apk.sh` do it) for LVGL glue. Add the TestPyPI packages to `buildozer.spec` `requirements`, set `p4a.extra_args` for TestPyPI, and point `p4a.local_recipes` at this repo's `p4a_recipes/`.

## Layout

| Path | Role |
|------|------|
| `android_demo/` | buildozer project + demos |
| `p4a_recipes/usdl2/` | TestPyPI `usdl2` recipe |
| `p4a_recipes/displaysys/` | TestPyPI `displaysys` recipe |
| `p4a_recipes/eventsys/` | TestPyPI `eventsys` recipe |
| `p4a_recipes/graphics/` | TestPyPI `graphics` recipe |
| `p4a_recipes/multimer/` | TestPyPI `multimer` recipe |
| `p4a_recipes/lvglcpython/` | TestPyPI `lvgl-cpython` recipe |
