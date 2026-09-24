if /I "%target_platform%"=="win-arm64" goto win_arm64

:: Trailing semicolon in this variable as set by current (2017/01)
:: conda-build breaks us. Manual fix:
set "MSYS2_ARG_CONV_EXCL=/AI;/AL;/OUT;/out"
:: Delegate to the Unixy script. We need to translate the key path variables
:: to be Unix-y rather than Windows-y, though.
set "saved_recipe_dir=%RECIPE_DIR%"
FOR /F "delims=" %%i IN ('cygpath.exe -u -p "%PATH%"') DO set "PATH_OVERRIDE=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -m "%BUILD_PREFIX%"') DO set "BUILD_PREFIX_M=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -m "%LIBRARY_PREFIX%"') DO set "LIBRARY_PREFIX_M=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%LIBRARY_PREFIX%"') DO set "LIBRARY_PREFIX_U=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%PREFIX%"') DO set "PREFIX=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%PYTHON%"') DO set "PYTHON=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%RECIPE_DIR%"') DO set "RECIPE_DIR=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%SP_DIR%"') DO set "SP_DIR=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%SRC_DIR%"') DO set "SRC_DIR=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%STDLIB_DIR%"') DO set "STDLIB_DIR=%%i"
bash -x %saved_recipe_dir%\build.sh
if errorlevel 1 exit 1
exit /b 0

:win_arm64
echo source %SYS_PREFIX:\=/%/etc/profile.d/conda.sh    > conda_build-arm64.sh
echo conda activate "${PREFIX}"                       >> conda_build-arm64.sh
echo conda activate --stack "${BUILD_PREFIX}"         >> conda_build-arm64.sh
echo CONDA_PREFIX=${CONDA_PREFIX//\\//}               >> conda_build-arm64.sh
type "%RECIPE_DIR%\build-arm64.sh"                          >> conda_build-arm64.sh

set PREFIX=%PREFIX:\=/%
set BUILD_PREFIX=%BUILD_PREFIX:\=/%
set CONDA_PREFIX=%CONDA_PREFIX:\=/%
set SRC_DIR=%SRC_DIR:\=/%
set MSYSTEM=UCRT64
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
bash -lc "./conda_build-arm64.sh"
if errorlevel 1 exit 1
