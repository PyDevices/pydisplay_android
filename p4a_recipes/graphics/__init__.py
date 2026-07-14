# SPDX-License-Identifier: MIT
"""python-for-android recipe: graphics-cmod (TestPyPI native Android wheel)."""

from pythonforandroid.recipe import PyProjectRecipe


class GraphicsRecipe(PyProjectRecipe):
    # buildozer requirement name stays "graphics"; pip installs graphics-cmod.
    version = None
    name = "graphics"
    depends = []
    call_hostpython_via_targetpython = False

    def get_pip_name(self):
        return "graphics-cmod"


recipe = GraphicsRecipe()
