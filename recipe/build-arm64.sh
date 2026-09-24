#!/bin/bash
set -euxo pipefail

# The shell is MSYS2; Clang and all generated code target native ARM64/MSVC.
export PREFIX="$PREFIX/Library"
cp "$BUILD_PREFIX/share/gnuconfig/"config.* build-aux/
# The patch updates configure and its macro sources together. Preserve the
# release-generated files instead of regenerating them with another Automake.
touch aclocal.m4 configure src/config.h.in \
    Makefile.in src/Makefile.in tests/Makefile.in doc/Makefile.in man/Makefile.in
export CFLAGS="$CFLAGS -std=gnu17"
export LIBS="${LIBS:-} -lpthread -lws2_32"
# The release Libtool file-magic test recognizes only x86 Windows imports.
# Let the native linker validate ARM64 import libraries.
export lt_cv_deplibs_check_method=pass_all
export PYTHON="$BUILD_PREFIX/python.exe"
# Native pkg-config uses semicolons; colons also occur in Windows drive paths.
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig;$PREFIX/share/pkgconfig;$BUILD_PREFIX/Library/share/pkgconfig"
export PATH="$PWD/src/.libs:$PATH"

# DRI3 and Present require Unix file-descriptor passing, unavailable on Win32.
./configure --build=aarch64-pc-mingw32 --host=aarch64-pc-mingw32 \
    --prefix="$PREFIX" --disable-static --disable-dependency-tracking \
    --disable-selective-werror --disable-devel-docs --without-doxygen \
    --disable-present
make -j"$CPU_COUNT"
make check -j"$CPU_COUNT"
make install

# Libtool may install DLLs beside the import libraries or directly in bin.
mkdir -p "$PREFIX/bin"
for dll in "$PREFIX"/lib/*xcb*.dll; do
    test ! -f "$dll" || mv "$dll" "$PREFIX/bin/"
done
for implib in "$PREFIX"/lib/*xcb*.dll.lib; do
    test -f "$implib"
    mv "$implib" "${implib%.dll.lib}.lib"
done
test -f "$PREFIX/bin/xcb-1.dll"
test -f "$PREFIX/lib/xcb.lib"

# MSVC consumers need dllimport for exported extension data, not functions.
"$PYTHON" - "$PREFIX" <<'PY'
from pathlib import Path
import sys
prefix = Path(sys.argv[1])
for path in (prefix / 'include/xcb').glob('*.h'):
    text = path.read_text()
    if 'extern xcb_extension_t' in text:
        path.write_text(text.replace('extern xcb_extension_t', '__declspec(dllimport) extern xcb_extension_t'))
PY
find "$PREFIX" -name '*.la' -delete
rm -rf "$PREFIX/share/man" "$PREFIX/share/doc/libxcb"
