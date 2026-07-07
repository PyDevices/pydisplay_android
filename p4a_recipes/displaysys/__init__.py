# SPDX-License-Identifier: MIT
"""python-for-android recipe: displaysys (TestPyPI wheel)."""

from pythonforandroid.recipe import PyProjectRecipe


class DisplaysysRecipe(PyProjectRecipe):
    version = "0.0.7"
    name = "displaysys"
    depends = []
    call_hostpython_via_targetpython = False


recipe = DisplaysysRecipe()
