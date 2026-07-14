# SPDX-License-Identifier: MIT
"""python-for-android recipe: lvgl-cpython (TestPyPI native Android wheel)."""

from pythonforandroid.recipe import PyProjectRecipe


class LvglCpythonRecipe(PyProjectRecipe):
    # Optional — not in the paint milestone buildozer.spec requirements.
    version = None
    name = "lvglcpython"
    depends = []
    call_hostpython_via_targetpython = False

    def get_pip_name(self):
        return "lvgl-cpython"


recipe = LvglCpythonRecipe()
