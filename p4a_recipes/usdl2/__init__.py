# SPDX-License-Identifier: MIT
"""python-for-android recipe: usdl2 (TestPyPI native Android wheel)."""

from pythonforandroid.recipe import PyProjectRecipe


class Usdl2Recipe(PyProjectRecipe):
    # Unpinned — pip installs latest usdl2 matching the Android wheel tag.
    version = None
    name = "usdl2"
    depends = ["sdl2"]
    call_hostpython_via_targetpython = False


recipe = Usdl2Recipe()
