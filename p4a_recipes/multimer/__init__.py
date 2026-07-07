# SPDX-License-Identifier: MIT
"""python-for-android recipe: multimer (TestPyPI wheel)."""

from pythonforandroid.recipe import PyProjectRecipe


class MultimerRecipe(PyProjectRecipe):
    version = "0.0.7"
    name = "multimer"
    depends = ["usdl2"]
    call_hostpython_via_targetpython = False


recipe = MultimerRecipe()
