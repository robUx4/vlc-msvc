#!/bin/sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

if [ "$PLATFORM" = "" ] ; then
    echo "\$PLATFORM is unset"
    exit 1
fi

if [ "$CONFIGURATION" = "" ] ; then
    echo "\$CONFIGURATION is unset"
    exit 1
fi

ROOT_FOLDER=$SCRIPTPATH/../
BUILD_FOLDER=$ROOT_FOLDER/vlc/${PLATFORM}_${CONFIGURATION}/

cd $BUILD_FOLDER

make install || exit 1

find _win32 -name *.la -exec rm {} \;
find _win32/lib/vlc -name *.lib -exec rm {} \;

mkdir tmp

cp -R _win32/include tmp/
cp -R _win32/lib/vlc/plugins tmp/
cp _win32/lib/vlc.dll.lib tmp/vlc.lib
cp _win32/bin/vlc.dll tmp/libvlc.dll
cp _win32/lib/vlccore.dll.lib tmp/vlccore.lib
cp _win32/bin/vlccore.dll tmp/libvlccore.dll

PACKAGE_FOLDER=./$PLATFORM/vlc-arm/$CONFIGURATION

if [ -d $PACKAGE_FOLDER ] ; then
    rm -rf $PACKAGE_FOLDER
fi
mkdir -p $PLATFORM/vlc-arm/
mv tmp $PACKAGE_FOLDER


