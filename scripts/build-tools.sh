#!/bin/sh


SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
ROOT_FOLDER=$SCRIPTPATH/..

cd $ROOT_FOLDER/vlc/extras/tools/
./bootstrap || exit 1

# we need a recent cmake as the one in msys2 doesn't support VS2015 output
#CXXFLAGS="-static -static-libgcc -static-libstdc++" CFLAGS="-static -static-libgcc -static-libstdc++" make .cmake || exit 1
make || exit 1
