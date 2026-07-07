[app]
title = pydisplay LVGL Android Demo
package.name = pydisplaydemo
package.domain = org.pydevices
source.dir = .
source.include_exts = py
source.main = main_lvgl.py
version = 0.4.0
requirements = python3==3.13,sdl2,usdl2,displaysys,eventsys,graphics,multimer,lvglcpython
orientation = landscape
fullscreen = 0
android.api = 31
android.minapi = 24
android.archs = arm64-v8a, armeabi-v7a
android.bootstrap = sdl2
android.permissions = INTERNET

# PyDevices wheels on TestPyPI (usdl2, displaysys, eventsys, graphics, multimer, lvgl-cpython).
p4a.extra_args = --extra-index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/

# Thin PyProjectRecipe wrappers that install matching TestPyPI wheels.
p4a.local_recipes = ../p4a_recipes

[buildozer]
log_level = 2
warn_on_root = 0
