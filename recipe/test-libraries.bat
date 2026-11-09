@echo off
if /I "%~1"=="arm64" (
    if not exist "%LIBRARY_BIN%\xcb-1.dll" exit /b 1
    if not exist "%LIBRARY_LIB%\xcb.lib" exit /b 1
    exit /b 0
)

if /I not "%~1"=="mingw" exit /b 1

for %%L in (
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
) do (
    if not exist "%LIBRARY_LIB%\lib%%L.dll.a" exit /b 1
    if not exist "%LIBRARY_BIN%\msys-%%L-*.dll" exit /b 1
)
exit /b 0
