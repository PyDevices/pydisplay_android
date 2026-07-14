# SPDX-License-Identifier: MIT
"""python-for-android recipe: displaysys (TestPyPI pure-Python wheel)."""

from pythonforandroid.recipe import PyProjectRecipe


class DisplaysysRecipe(PyProjectRecipe):
    version = None
    name = "displaysys"
    depends = []
    call_hostpython_via_targetpython = False


recipe = DisplaysysRecipe()
