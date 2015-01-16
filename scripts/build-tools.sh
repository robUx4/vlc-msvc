#!/bin/sh


SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
ROOT_FOLDER=$SCRIPTPATH/..

cd $ROOT_FOLDER/vlc/extras/tools/
./bootstrap || exit 1
make || exit 1
