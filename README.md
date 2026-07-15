# pydisplay_android

Android APK template for [pydisplay](https://github.com/PyDevices/pydisplay): **python-for-android** recipes and a **buildozer** app (`p4a_app/`) others can clone and replace with their own code.

On Android there is no MicroPython port; pydisplay runs under **CPython** in a **python-for-android** APK with the **SDL2 bootstrap**. Runtime packages install from **[TestPyPI](https://test.pypi.org/)** — not from local git checkouts.

## TestPyPI packages

| PyPI name | Import | Role |
|-----------|--------|------|
| [usdl2](https://test.pypi.org/project/usdl2/) | `usdl2` | Native SDL2 subset (Android wheels: `android_21_*`) |
| [graphics-cmod](https://test.pypi.org/project/graphics-cmod/) | `graphics` | Native graphics (`graphics` recipe → `graphics-cmod`) |
| [displaysys](https://test.pypi.org/project/displaysys/) | `displaysys` | Display core + backends (`SDLDisplay`, …) |
| [eventsys](https://test.pypi.org/project/eventsys/) | `eventsys` | Event runtime / input queue |
| [multimer](https://test.pypi.org/project/multimer/) | `multimer` | Timers (`_sdl2` backend on Android) |
| [lvgl-cpython](https://test.pypi.org/project/lvgl-cpython/) | `lvgl` | LVGL native extension (optional; not in paint `requirements`) |

Recipes leave versions unpinned so pip takes the latest matching wheel. Pin with `version = "…"` in a recipe when you need a frozen APK.

LVGL glue (`display_driver.py`, `lv_utils.py`) can be fetched from [pydisplay on GitHub](https://github.com/PyDevices/pydisplay) with `FETCH_LVGL_ADDONS=1 ./build_android.sh`.

## 🚀 Build APK

Prerequisites: [Android SDK + NDK](https://python-for-android.readthedocs.io/en/latest/quickstart.html), Ubuntu/WSL build tools (`git`, `zip`, `openjdk-17-jdk`, `autoconf`, …). Tooling already downloaded by buildozer lives under `~/.buildozer/android/platform/` by default.

```bash
./build_android.sh              # prompts for launcher title (Enter = current)
./build_android.sh -y           # keep current title (CI / automation)
./build_android.sh --title Paint
# APK: p4a_app/bin/p4a_app-0.5.0-*-debug.apk (name may vary)
./scripts/emulator.sh
```

`build_android.sh` creates `.venv/` and installs host deps from `requirements.txt`. Package id: **`org.pydevices.p4a_app`**. Launcher label comes from `title` in `p4a_app/buildozer.spec`.

### Icon and presplash

`buildozer.spec` points both at the same asset:

```ini
icon.filename = %(source.dir)s/icon.png
presplash.filename = %(source.dir)s/icon.png
```

| Spec | Details |
|------|---------|
| File | `p4a_app/icon.png` (default: copy of [PyDevices logo-512.png](https://github.com/PyDevices/PyDevices.github.io/blob/main/assets/img/logo-512.png)) |
| Format | PNG, square, RGBA preferred |
| Size | **512×512** (buildozer resizes into density buckets) |
| `icon` | Launcher / home-screen icon |
| `presplash` | Startup splash while Python/SDL bootstrap |

Replace `icon.png` (or change the paths) and rebuild for a new look.

## App layout

| File | Role |
|------|------|
| `p4a_app/main.py` | p4a entry: `import lib.path` then `import paint` |
| `p4a_app/paint.py` | Touch-paint (default APK behavior) |
| `p4a_app/board_config.py` | SDL display + `eventsys.Runtime` (from pydisplay sdldisplay idiom) |
| `p4a_app/lib/path.py` | `sys.path` helper (same idea as pydisplay `lib.path`) |
| `p4a_app/icon.png` | Launcher icon + presplash (see above) |

`buildozer.spec` paint requirements:

```
python3,sdl2,usdl2,displaysys,eventsys,graphics,multimer
```

(`python3` unpinned — p4a pairs target/host Python; do not pin `python3==3.13`.)

## Desktop smoke test (Xvfb)

```bash
./scripts/test_desktop.sh
```

## Emulator / phone

```bash
./scripts/emulator.sh          # AVD already running (WSL → use Windows AVD + adb.exe)
./scripts/phone.sh             # USB-connected phone (skips emulators)
```

On WSL, start the AVD from **Windows** (Device Manager ▶), then talk to it with Windows `adb.exe` (e.g. a `~/bin/adb.exe` symlink to `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`).

### USB debugging on a Samsung phone (One UI)

USB debugging is hidden until Developer options are unlocked, and Samsung **Auto Blocker** can leave it greyed out (“blocked by auto blocker”).

1. **Settings → About phone → Software information** → tap **Build number** seven times (unlock Developer options).
2. If USB debugging says blocked by Auto Blocker:
   - **Settings → Security and privacy → Auto Blocker** → turn the **main switch off** (PIN/fingerprint if asked).
3. **Settings → Developer options** → enable **USB debugging** → OK.
4. Plug in a data USB cable; accept **Allow USB debugging?** on the phone.
5. Confirm from WSL: `adb.exe devices` shows a non-`emulator-*` line as `device`, then run `./scripts/phone.sh`.

You can turn Auto Blocker back on afterward; USB debugging may be blocked again until you disable it.

### Android SDK Command-line Tools (`sdkmanager`)

A Studio-installed SDK often has no `cmdline-tools/` folder until you add it. Without that package there is no `sdkmanager.bat` for CLI image installs.

1. Android Studio → **Settings → Languages & Frameworks → Android SDK → SDK Tools**
2. Check **Android SDK Command-line Tools (latest)** → Apply
3. The batch file lands at:

```text
%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat
```

From WSL that path is typically:

```text
/mnt/c/Users/<you>/AppData/Local/Android/Sdk/cmdline-tools/latest/bin/sdkmanager.bat
```

Example (AMD64 Windows — use an **x86_64** system image, not arm64):

```bat
"%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" ^
  "system-images;android-37.1;google_apis_playstore_ps16k;x86_64"
```

An arm64 AVD on AMD64 Windows exits immediately (“emulator process for AVD … has terminated”). Until cmdline-tools are installed, download images from Studio’s Device Manager / SDK Manager UI instead.

## Your own app

Almost everything a user customizes for their APK lives under **`p4a_app/`**:

| Customize | Where |
|-----------|--------|
| Entry / demo code | `p4a_app/main.py`, `paint.py` (or your module + the `import` in `main.py`) |
| Display / window | `p4a_app/board_config.py` |
| Title, package id, orientation, version, permissions, `requirements` | `p4a_app/buildozer.spec` |
| Icon / presplash | `p4a_app/icon.png` (paths in the spec) |

Leave **`p4a_app/`** alone only when you need packaging or host tooling changes:

| Need | Where |
|------|--------|
| New / different TestPyPI wheel install | `p4a_recipes/` (+ list the recipe name in `buildozer.spec` `requirements`) |
| Build / install / smoke helpers | `build_android.sh`, `scripts/` |

Keep `p4a.local_recipes` pointed at this repo’s `p4a_recipes/` unless you are shipping your own recipe tree.

## Layout

| Path | Role |
|------|------|
| `p4a_app/` | buildozer project + sample entry |
| `p4a_recipes/` | TestPyPI `PyProjectRecipe` wrappers |
| `scripts/` | Host helpers (`phone.sh`, `emulator.sh`, `test_desktop.sh`, …) |
| `build_android.sh` | Build the debug APK |
