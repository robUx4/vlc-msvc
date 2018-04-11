#!/bin/sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

if [ "$VLC_PLATFORM" = "" ] ; then
    echo "\$VLC_PLATFORM is unset"
    exit 1
fi

if [ "$MSVC_ARCH" = "" ] ; then
    echo "\$MSVC_ARCH is unset"
    exit 1
fi

if [ "$VLC_CONFIGURATION" = "" ] ; then
    echo "\$VLC_CONFIGURATION is unset"
    exit 1
fi

ROOT_FOLDER=$SCRIPTPATH/../
BUILD_FOLDER=${ROOT_FOLDER}vlc/${ABI_VARIANT}/

cd $BUILD_FOLDER

make install || exit 1

find _win32 -name *.la -exec rm {} \;
find _win32/lib/vlc -name *.lib -exec rm {} \;

mkdir tmp

cp -R _win32/include tmp/
cp -R _win32/lib/vlc/plugins    \
        _win32/lib/libvlc.lib   \
        _win32/bin/libvlc.dll   \
        _win32/lib/libvlccore.lib  \
        _win32/bin/libvlccore.dll  \
        tmp

mkdir -p ${ROOT_FOLDER}../libvlc/$VLC_PLATFORM/vlc-$MSVC_ARCH/$VLC_CONFIGURATION
PACKAGE_FOLDER=${ROOT_FOLDER}../libvlc/$VLC_PLATFORM/vlc-$MSVC_ARCH/$VLC_CONFIGURATION

if [ -d $PACKAGE_FOLDER ] ; then
    rm -rf $PACKAGE_FOLDER
fi
mv -v tmp $PACKAGE_FOLDER


