# SPDX-License-Identifier: MIT
"""
Board configuration for Android TV / Fire OS (landscape, 10-foot UI).

Why landscape 1280x720: TV remotes and leanback launchers assume landscape;
phone paint uses portrait 720x1280. Fullscreen desktop flags match the phone
Android path so SDL letterboxes to the HDMI mode.
"""

import sys

import eventsys
import usdl2
from displaysys.sdldisplay import SDLDisplay as DTDisplay
from displaysys.sdldisplay import get_events

# Why 1280x720: common TV logical framebuffer for 10-foot UI (readable from sofa).
width = 1280
height = 720
rotation = 0
scale = 1.0

if sys.platform == "android":
    title = f"{sys.implementation.name} on android-tv"
    window_flags = usdl2.SDL_WINDOW_FULLSCREEN_DESKTOP | usdl2.SDL_WINDOW_ALLOW_HIGHDPI
else:
    title = f"{sys.implementation.name} on {sys.platform} (android-tv preview)"
    window_flags = usdl2.SDL_WINDOW_SHOWN | usdl2.SDL_WINDOW_ALLOW_HIGHDPI

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
