#!/bin/sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

if [ "$VLC_PLATFORM" = "" ] ; then
    echo "\$VLC_PLATFORM is unset"
    exit 1
fi

if [ "$VLC_CONFIGURATION" = "" ] ; then
    echo "\$VLC_CONFIGURATION is unset"
    exit 1
fi

ROOT_FOLDER=$SCRIPTPATH/../
BUILD_FOLDER=$ROOT_FOLDER/vlc/${VLC_PLATFORM}_${VLC_CONFIGURATION}/
if [ ! -d $BUILD_FOLDER ]; then
    mkdir $BUILD_FOLDER
fi
cd $BUILD_FOLDER
SRC_FOLDER=$BUILD_FOLDER/../

if [ ! -f $SRC_FOLDER/configure ] || [ "$SRC_FOLDER/configure" -ot "$SRC_FOLDER/configure.ac" ] ; then
    echo "Bootstraping..."
    dos2unix $SRC_FOLDER/configure.ac
    $SRC_FOLDER/bootstrap || exit 1
fi

case $VLC_CONFIGURATION in
    Debug)
        DEBUG_MODE=--enable-debug
        ;;
    Release)
        DEBUG_MODE=--disable-debug
        ;;
esac

if [ ! -f $BUILD_FOLDER/Makefile ] || [ $BUILD_FOLDER/Makefile -ot $SRC_FOLDER/configure.ac ] ; then
    echo "Running configure..."
    export PKG_CONFIG_PATH=$ROOT_FOLDER/vlc/contrib/$VLC_PLATFORM/lib/pkgconfig
    #Lua is compiled fine, but configure.ac tries to run luac while checking for it... since it's an arm binary...
    $SCRIPTPATH/../vlc/configure \
        --host=$BUILD_HOST \
        --build=x86-w64-mingw32 \
        --enable-winstore-app \
        $DEBUG_MODE \
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
        --disable-atmo \
        --disable-vlc \
        --disable-vcd \
        --disable-smbclient || exit 1
    # Force libtool to generate what we want
    sed -i 's/libname_spec=\"\\$name\"/libname_spec=\"lib\\$name\"/' libtool
    sed -i 's/library_names_spec=\"\\$libname.dll.lib\"/library_names_spec=\"\\$libname.lib\"/' libtool
    sed -i 's/$libname.dll.lib/$library_names_spec/g' libtool
fi

echo "Lauching build"
make -j`nproc` || exit 1
#make V=1 || exit 1
