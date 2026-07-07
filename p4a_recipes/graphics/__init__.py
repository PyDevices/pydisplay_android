# SPDX-License-Identifier: MIT
"""python-for-android recipe: graphics (TestPyPI wheel)."""

from pythonforandroid.recipe import PyProjectRecipe


class GraphicsRecipe(PyProjectRecipe):
    version = "0.0.3"
    name = "graphics"
    depends = []
    call_hostpython_via_targetpython = False


recipe = GraphicsRecipe()
