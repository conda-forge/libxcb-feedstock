#!/bin/bash
set -euxo pipefail

libraries=(
    xcb
    xcb-composite
    xcb-damage
    xcb-dpms
    xcb-dri2
    xcb-glx
    xcb-present
    xcb-randr
    xcb-record
    xcb-res
    xcb-screensaver
    xcb-shape
    xcb-shm
    xcb-sync
    xcb-xf86dri
    xcb-xfixes
    xcb-xinerama
    xcb-xkb
    xcb-xtest
    xcb-xv
    xcb-xvmc
    xcb-dri3
    xcb-render
    xcb-xinput
)

for lib in "${libraries[@]}"; do
    test -f "$PREFIX/lib/lib${lib}${SHLIB_EXT}"
done
