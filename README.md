# pydisplay_android

Android APK template for [pydisplay](https://github.com/PyDevices/pydisplay): **python-for-android** recipes and a **buildozer** app (`p4a_app/`) others can clone and replace with their own code.

On Android there is no MicroPython port; pydisplay runs under **CPython** in a **python-for-android** APK with the **SDL2 bootstrap**. Runtime packages install from **[TestPyPI](https://test.pypi.org/)** — not from local git checkouts.

## TestPyPI packages

| PyPI name | Import | Role |
|-----------|--------|------|
| [usdl2](https://test.pypi.org/project/usdl2/) | `usdl2` | Native SDL2 subset (Android wheels: `android_21_*`) |
| [graphics-cmod](https://test.pypi.org/project/graphics-cmod/) | `graphics` | Native graphics (`graphics` recipe → `graphics-cmod`) |
| [displaysys](https://test.pypi.org/project/displaysys/) | `displaysys` | Display drivers (`SDLDisplay`, …) |
| [eventsys](https://test.pypi.org/project/eventsys/) | `eventsys` | Event broker / input queue |
| [multimer](https://test.pypi.org/project/multimer/) | `multimer` | Timers (`_sdl2` backend on Android) |
| [lvgl-cpython](https://test.pypi.org/project/lvgl-cpython/) | `lvgl` | LVGL native extension (optional; not in paint `requirements`) |

Recipes leave versions unpinned so pip takes the latest matching wheel. Pin with `version = "…"` in a recipe when you need a frozen APK.

LVGL glue (`display_driver.py`, `lv_utils.py`) can be fetched from [pydisplay on GitHub](https://github.com/PyDevices/pydisplay) with `FETCH_LVGL_ADDONS=1 ./build_android.sh`.

## 🚀 Build APK

Prerequisites: [Android SDK + NDK](https://python-for-android.readthedocs.io/en/latest/quickstart.html), Ubuntu/WSL build tools (`git`, `zip`, `openjdk-17-jdk`, `autoconf`, …). Tooling already downloaded by buildozer lives under `~/.buildozer/android/platform/` by default.

```bash
./build_android.sh
# APK: p4a_app/bin/p4a_app-0.5.0-*-debug.apk (name may vary)
./scripts/emulator.sh
```

`build_android.sh` creates `.venv/` and installs host deps from `requirements.txt`. `p4a_app/build_apk.sh` is a thin wrapper. Package id: **`org.pydevices.p4a_app`**.

## App layout

| File | Role |
|------|------|
| `p4a_app/main.py` | p4a entry: `import lib.path` then `import paint` |
| `p4a_app/paint.py` | Touch-paint (default APK behavior) |
| `p4a_app/board_config.py` | SDL display + `eventsys.Runtime` (from pydisplay sdldisplay idiom) |
| `p4a_app/lib/path.py` | `sys.path` helper (same idea as pydisplay `lib.path`) |

`buildozer.spec` paint requirements:

```
python3,sdl2,usdl2,displaysys,eventsys,graphics,multimer
```

(`python3` unpinned — p4a pairs target/host Python; do not pin `python3==3.13`.)

## Desktop smoke test (Xvfb)

```bash
cd pydisplay_android/p4a_app
./test_desktop.sh
```

## Emulator / phone

```bash
./scripts/emulator.sh          # AVD already running (WSL → use Windows AVD + adb.exe)
./scripts/phone.sh             # USB debugging
```

## Your own app

Keep `p4a_app/` as the buildozer project: replace `paint.py` (and point `main.py` at your module), keep or adapt `board_config.py`, and adjust `requirements` / `p4a_recipes/` as needed.

## Layout

| Path | Role |
|------|------|
| `p4a_app/` | buildozer project + sample entry |
| `p4a_recipes/` | TestPyPI `PyProjectRecipe` wrappers |
