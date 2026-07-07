# SPDX-License-Identifier: MIT
"""python-for-android recipe: usdl2 (TestPyPI wheel)."""

from pythonforandroid.recipe import PyProjectRecipe


class Usdl2Recipe(PyProjectRecipe):
    version = "0.0.1"
    name = "usdl2"
    depends = ["sdl2"]
    call_hostpython_via_targetpython = False

    def get_pip_name(self):
        return "usdl2==0.0.1"


recipe = Usdl2Recipe()
