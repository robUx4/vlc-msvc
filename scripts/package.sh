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

cd $BUILD_FOLDER

make install || exit 1

find _win32 -name *.la -exec rm {} \;
find _win32/lib/vlc -name *.lib -exec rm {} \;

mkdir tmp

cp -R _win32/include tmp/
cp -R _win32/lib/vlc/plugins tmp/
cp _win32/lib/vlc.dll.lib tmp/vlc.lib
cp _win32/bin/vlc.dll tmp/
cp _win32/lib/vlccore.dll.lib tmp/vlccore.lib
cp _win32/bin/vlccore.dll tmp/

cd tmp/plugins
for f in */ ; do
    cd $f
    for i in *.dll ; do
        mv $i lib$i
    done
    cd ..
done
cd ../../


mkdir -p $ROOT_FOLDER/$VLC_PLATFORM/vlc-arm/
PACKAGE_FOLDER=$ROOT_FOLDER/$VLC_PLATFORM/vlc-arm/$VLC_CONFIGURATION

if [ -d $PACKAGE_FOLDER ] ; then
    rm -rf $PACKAGE_FOLDER
fi
mv tmp $PACKAGE_FOLDER


