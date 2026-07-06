# pydisplay_android

Android APK integration for [pydisplay](https://github.com/PyDevices/pydisplay): **python-for-android** recipes, a **buildozer** demo, and desktop smoke tests.

On Android there is no MicroPython port; pydisplay runs under **CPython** in a **python-for-android** APK with the **SDL2 bootstrap**. The `import usdl2` API comes from the ctypes FFI package in [usdl2 `python/usdl2/`](https://github.com/PyDevices/usdl2/tree/main/python/usdl2). pydisplay's existing `SDLDisplay` backend works unchanged once `usdl2` is installed.

## Workspace layout

Clone these repos as siblings (e.g. under a `cmods` workspace):

```bash
git clone https://github.com/PyDevices/usdl2.git
git clone https://github.com/PyDevices/pydisplay.git
git clone https://github.com/PyDevices/lv_cpython_mod.git
git clone https://github.com/PyDevices/pydisplay_android.git
```

| Repo | Role |
|------|------|
| [usdl2](https://github.com/PyDevices/usdl2) | CPython ctypes `usdl2` + `p4a_recipes/usdl2/` |
| [pydisplay](https://github.com/PyDevices/pydisplay) | `SDLDisplay`, `eventsys`, `multimer`, `display_driver.py` |
| [lv_cpython_mod](https://github.com/PyDevices/lv_cpython_mod) | `lvgl-cpython` wheels / source (optional for LVGL demo) |
| **pydisplay_android** (this repo) | Demo APK, `pydisplay` + `lvglcpython` p4a recipes |

## Build demo APK

Prerequisites: [Android SDK + NDK](https://python-for-android.readthedocs.io/en/latest/quickstart.html), `pip install buildozer`, sibling `usdl2` clone.

```bash
cd pydisplay_android/android_demo
./build_apk.sh
# APK: android_demo/bin/pydisplaydemo-0.3.0-*-debug.apk (name may vary)
adb install -r bin/*.apk
```

`build_apk.sh` symlinks `usdl2`'s p4a recipe into `p4a_recipes/usdl2/`. If `../pydisplay` exists, it sets `P4A_pydisplay_DIR` for an in-tree pydisplay build. Set `P4A_lvgl_cpython_DIR` to a sibling `lv_cpython_mod` clone for in-tree LVGL source builds (`git submodule update --init lvgl` required).

## pydisplay + LVGL on Android

The demo APK uses **pydisplay** (`SDLDisplay`, `eventsys`, `multimer`) and **lvgl-cpython** via p4a recipes:

| File | Role |
|------|------|
| `p4a_recipes/pydisplay/` | Installs `displaysys`, `eventsys`, `graphics`, `multimer`; copies `display_driver.py` + `lv_utils.py` to site-packages |
| `p4a_recipes/lvglcpython/` | `PyProjectRecipe` for `lvgl-cpython` — TestPyPI prebuilt wheel (`android_21_arm64_v8a`, …) or source fallback |
| `android_demo/board_config.py` | SDL display + event broker (landscape, fullscreen on Android) |
| `android_demo/main_lvgl.py` | LVGL touch grid demo (`import display_driver`) — default APK entry |
| `android_demo/main.py` | Touch-paint demo without LVGL |
| `android_demo/main_usdl2_raw.py` | Raw `usdl2` reference demo (no pydisplay) |

`buildozer.spec` requirements: `python3,sdl2,usdl2,pydisplay,lvglcpython` with `p4a.extra_index_url` for TestPyPI wheels.

On Android, **multimer** selects the **`_sdl2`** backend (SDL timers on the UI thread) when `usdl2` is available — not `_threading`.

## Desktop smoke test (Xvfb)

Requires sibling `usdl2` and `pydisplay` clones:

```bash
cd pydisplay_android/android_demo
./test_desktop.sh
```

For LVGL smoke, also clone `lv_cpython_mod` beside this repo (or set `LVCPY_DIR`).

## Your own app

Copy `android_demo/board_config.py`, add `pydisplay` + `usdl2` to `buildozer.spec`, point `p4a.local_recipes` at this repo's `p4a_recipes/` (run `build_apk.sh` once to link the `usdl2` recipe), and write your main loop with `display_drv` / `broker` as usual.

## Layout

| Path | Role |
|------|------|
| `android_demo/` | buildozer project + touch-paint and LVGL demos |
| `p4a_recipes/pydisplay/` | python-for-android recipe (depends on `usdl2`) |
| `p4a_recipes/lvglcpython/` | python-for-android recipe for `lvgl-cpython` |
