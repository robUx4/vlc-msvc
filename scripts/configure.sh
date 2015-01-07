#!/bin/sh

export CC="$HOME/wrappers/windowsphone/clwrap"
export CXX="$CC"
export cc=$CC
export cxx=$CXX
export AR="$HOME/wrappers/arwrap"
export NM="dumpbin.exe -symbols"
#export nm=$NM
export AS=armasm
#export as=$AS
export LD="$HOME/wrappers/ldwrap"
export CCLD="$LD"
export CXXLD="$CCLD"
export RC=rc.exe
export WINDRES="$HOME/wrappers/windreswrap"
export RANLIB=true
export PATH="$HOME/wrappers:$HOME/vlc/extra/tools/ragel/ragel:$PATH"
export HAVE_ARMV7A=true
export HAVE_VISUALSTUDIO=true
export HAVE_WINPHONE=true
export LDFLAGS="-avoid-version"
# Prevent some broken MSYS conversions
# Mind that having a terminal ';' would make empty string a token
# that would be compared against, thus not translating anything
export MSYS2_ARG_CONV_EXCL="-OUT:;-out:;-LIBPATH:;-libpath:"
export BUILD_HOST=arm-msvc-mingw32winrt
export PKG_CONFIG_PATH=$HOME/vlc/contrib/$BUILD_HOST/lib/pkgconfig

#Lua is compiled fine, but configure.ac tries to run luac while checking for it... since it's an arm binary...
../configure \
	--host=$BUILD_HOST \
    --build=x86-w64-mingw32 \
    --enable-winstore-app \
    --enable-debug \
	--disable-sout \
	--enable-flac \
	--disable-lua \
	--disable-flac \
	--disable-theora \
	--enable-avcodec \
	--enable-merge-ffmpeg \
	--enable-dca \
	--enable-mpc \
	--enable-libass \
	--enable-schroedinger \
	--disable-dvdread \
    --disable-dvdnav \
	--enable-shout \
	--enable-goom \
	--disable-caca \
	--disable-sdl \
	--disable-qt \
	--disable-skins2 \
	--enable-sse \
	--enable-mmx \
	--enable-libcddb \
	--disable-zvbi \
	--disable-telx \
	--enable-nls \
	--disable-mad \
	--disable-dca \
	--disable-schroedinger \
	--disable-theora \
	--disable-goom \
	--disable-libgcrypt \
	--disable-dbus \
    --disable-archive \
    --disable-crystalhd \
    --disable-aribsub \
    --disable-x265 \
    --disable-x264 \
    --disable-vpx \
    --disable-upnp \
    --disable-gnutls \
    --disable-postproc \
    --disable-projectm \
    --disable-dxva2 \
    --disable-screen \
    --disable-libcddb \
    --disable-bluray \
    --disable-wasapi \
    --disable-atmo \
    --disable-vlc \
    --disable-vcd \
    --disable-directx
    