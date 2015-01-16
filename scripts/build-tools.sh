#!/bin/sh


SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
ROOT_FOLDER=$SCRIPTPATH/..

cd $ROOT_FOLDER/vlc/extras/tools/
./bootstrap || exit 1
# Work around failing tar xz detection on msys2
touch $ROOT_FOLDER/vlc/extras/tools/.tar
touch $ROOT_FOLDER/vlc/extras/tools/.xz
make || exit 1
