# SPDX-License-Identifier: MIT
"""Dev/APK helper: put sibling dirs on sys.path (same idea as pydisplay ``lib.path``).

Usage::

    import lib.path  # noqa: F401
    import paint
"""

directories = ["lib", "add_ons", "examples"]
prepend_directories = []
RELPATH = True


def update():
    import os
    import sys

    def find_dir(directory):
        try:
            os.stat(directory)
            return True
        except OSError:
            return False

    def resolve_entry(directory):
        is_abs = directory.startswith("/") or (len(directory) > 1 and directory[1] == ":")
        target = directory if is_abs else cwd + directory
        if not find_dir(target):
            return None
        return target if is_abs or not RELPATH else directory

    cwd = os.getcwd()
    if cwd[-1] != "/":
        cwd += "/"

    for directory in prepend_directories:
        entry = resolve_entry(directory)
        if entry is not None and entry not in sys.path:
            sys.path.insert(0, entry)

    for directory in directories:
        entry = resolve_entry(directory)
        if entry is not None and entry not in sys.path:
            sys.path.append(entry)


def add(directory, first=False):
    if first:
        prepend_directories.append(directory)
    else:
        directories.append(directory)
    update()


update()
