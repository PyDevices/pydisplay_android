[app]
title = pydisplay p4a_app
package.name = p4a_app
package.domain = org.pydevices
source.dir = .
source.include_exts = py
source.main = main.py
version = 0.5.0
# Paint milestone: no LVGL. Native wheels: usdl2, graphics-cmod (via graphics recipe).
requirements = python3,sdl2,usdl2,displaysys,eventsys,graphics,multimer
orientation = portrait
fullscreen = 0
android.api = 31
android.minapi = 24
android.archs = arm64-v8a, armeabi-v7a
android.bootstrap = sdl2
android.permissions = INTERNET

# PyDevices wheels on TestPyPI (unpinned recipes install latest matching wheel).
p4a.extra_args = --extra-index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/

# Thin PyProjectRecipe wrappers that install matching TestPyPI wheels.
p4a.local_recipes = ../p4a_recipes

[buildozer]
log_level = 2
warn_on_root = 0
