# SPDX-License-Identifier: MIT
"""
Board configuration for Android (p4a) and desktop SDL.

Based on pydisplay ``board_configs/sdldisplay/board_config.py`` and the
default desktop / ``Runtime`` idiom in ``src/lib/board_config.py``.
"""

import sys

import eventsys
import usdl2
from displaysys.sdldisplay import SDLDisplay as DTDisplay
from displaysys.sdldisplay import get_events

# Portrait phone logical framebuffer (HD); SDL letterboxes to the device window.
# Matches buildozer orientation=portrait. paint.py lays out from width/height.
width = 720
height = 1280
rotation = 0
scale = 1.0

if sys.platform == "android":
    title = f"{sys.implementation.name} on android"
    window_flags = usdl2.SDL_WINDOW_FULLSCREEN_DESKTOP | usdl2.SDL_WINDOW_ALLOW_HIGHDPI
else:
    title = f"{sys.implementation.name} on {sys.platform}"
    window_flags = usdl2.SDL_WINDOW_SHOWN | usdl2.SDL_WINDOW_ALLOW_HIGHDPI
    # Desktop window starts 1:1; SDLDisplay may shrink scale to fit the host desktop.
    scale = 1.0


display_drv = DTDisplay(
    width=width,
    height=height,
    rotation=rotation,
    title=title,
    scale=scale,
    window_flags=window_flags,
)

runtime = eventsys.Runtime(display=display_drv, host_read=get_events)

display_drv.fill(0)
