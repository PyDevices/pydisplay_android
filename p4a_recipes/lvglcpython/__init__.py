# SPDX-License-Identifier: MIT
"""python-for-android recipe: lvgl-cpython (TestPyPI Android wheel)."""

from pythonforandroid.recipe import PyProjectRecipe


class LvglCpythonRecipe(PyProjectRecipe):
    version = "9.5.6"
    name = "lvglcpython"
    depends = []
    call_hostpython_via_targetpython = False

    def get_pip_name(self):
        return "lvgl-cpython==9.5.6"


recipe = LvglCpythonRecipe()
