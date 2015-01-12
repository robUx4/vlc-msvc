#!/bin/sh

# This assumes we're running in vlc-msvc root folder

usage()
{
    echo "./build.sh <platform> <configuration>"
    echo "platform: Windows|WindowsPhone"
    echo "configuration: Debug|Release"
}

case $1 in
    Windows)
        export PLATFORM=Windows
        ;;
    WP|WindowsPhone)
        export PLATFORM=WindowsPhone
        ;;
    *)
        usage
        exit 1
esac

shift

case $1 in
    Debug)
        export CONFIGURATION=Debug
        ;;
    Release)
        export CONFIGURATION=Release
        ;;
    *)
        usage
        exit 1
esac

shift

if [ "$1" = "pause" ] ; then
	PAUSE_AFTER_BUILD=1
fi


SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
ROOT_FOLDER=$SCRIPTPATH/..

cd $ROOT_FOLDER

TESTED_HASH=969a8451cc02885a0fb411da1216667f2f38a302
if [ ! -d $"vlc" ]; then
    echo "VLC source not found, cloning"
    git clone git://git.videolan.org/vlc.git vlc
    cd vlc
    git checkout $TESTED_HASH
    git am -3 ../patches/*.patch
    if [ $? -ne 0 ]; then
        git am --abort
        echo "Applying the patches failed, aborting git-am"
        exit 1
    fi
else
    echo "VLC source found"
    cd vlc
    if ! git cat-file -e ${TESTED_HASH}; then
        cat << EOF
***
*** Error: Your vlc checkout does not contain the latest tested commit ***
***

EOF
        exit 1
    fi
fi

# Set required environment variables:
export CC="$ROOT_FOLDER/wrappers/clwrap"
export CXX="$CC"
export cc=$CC
export cxx=$CXX
export AR="$ROOT_FOLDER/wrappers/arwrap"
export NM="dumpbin.exe -symbols"
export AS=armasm
export LD="$ROOT_FOLDER/wrappers/ldwrap"
export CCLD="$LD"
export CXXLD="$CCLD"
export RANLIB=true
export RC=rc.exe
export WINDRES="$ROOT_FOLDER/wrappers/windreswrap"
#export PATH="$HOME/vlc/extra/tools/ragel/ragel:$PATH"
export PATH="$ROOT_FOLDER/wrappers:$PATH"
export HAVE_ARMV7A=true
export HAVE_VISUALSTUDIO=true
# Prevent some broken MSYS conversions
# Mind that having a terminal ';' would make empty string a token
# that would be compared against, thus not translating anything
export MSYS2_ARG_CONV_EXCL="/OUT:;-OUT:;-out:;-LIBPATH:;-libpath:"

if [ "$PLATFORM" = "WindowsPhone" ] ; then
    export HAVE_WINPHONE=true
    export BUILD_HOST=arm-msvc-mingw32winphone
else
    export HAVE_WINDOWSRT=true
    export BUILD_HOST=arm-msvc-mingw32winrt
fi

# We are now in ROOT_FOLDER/vlc
sh $ROOT_FOLDER/scripts/build-contribs.sh && \
	sh $ROOT_FOLDER/scripts/build-vlc.sh


if [ "$PAUSE_AFTER_BUILD" != "" ] ; then
	read -n1 -r -p "Press any key to continue..."
fi
