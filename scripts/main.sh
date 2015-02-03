#!/bin/sh

# This assumes we're running in vlc-msvc root folder

for i in $@ ; do
    if [ "$i" = "pause" ] ; then
        PAUSE_AFTER_BUILD=1
    fi
done

terminate()
{
if [ "$PAUSE_AFTER_BUILD" != "" ] ; then
	read -n1 -r -p "Press any key to continue..."
fi
exit $1
}

usage()
{
    echo "./build.sh <platform> <configuration>"
    echo "platform: Windows|WindowsPhone"
    echo "configuration: Debug|Release"
    terminate 1
}

case $1 in
    Windows)
        export VLC_PLATFORM=Windows
        ;;
    WP|WindowsPhone)
        export VLC_PLATFORM=WindowsPhone
        ;;
    *)
        usage
        ;;
esac

shift

case $1 in
    Debug)
        export VLC_CONFIGURATION=Debug
        ;;
    Release)
        export VLC_CONFIGURATION=Release
        ;;
    *)
        usage
        ;;
esac

shift


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
        terminate 1
    fi
    # Ugly hack. To be done only once:
    dos2unix ../src/ebml/*.patch
    dos2unix ../src/openjpeg/*.patch
else
    echo "VLC source found"
    cd vlc
    if ! git cat-file -e ${TESTED_HASH}; then
        cat << EOF
***
*** Error: Your vlc checkout does not contain the latest tested commit ***
***

EOF
        terminate 1
    fi
fi

# Run this before playing with our environment, except for the path,
# since we want the tools we already built to be detected
export PATH="$ROOT_FOLDER/vlc/extras/tools/build/bin:$PATH"
sh $SCRIPTPATH/build-tools.sh || terminate 1

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
#export RC=rc.exe
export WINDRES="$ROOT_FOLDER/wrappers/windreswrap"
export PATH="$ROOT_FOLDER/wrappers:$PATH"
export HAVE_ARMV7A=true
export HAVE_VISUALSTUDIO=true
# Prevent some broken MSYS conversions
# Mind that having a terminal ';' would make empty string a token
# that would be compared against, thus not translating anything
export MSYS2_ARG_CONV_EXCL="/OUT:;-OUT:;-out:;-LIBPATH:;-libpath:"

if [ "$VLC_PLATFORM" = "WindowsPhone" ] ; then
    export HAVE_WINPHONE=true
    export BUILD_HOST=arm-msvc-mingw32winphone
else
    export HAVE_WINDOWSRT=true
    export BUILD_HOST=arm-msvc-mingw32winrt
fi

# We are now in ROOT_FOLDER/vlc
sh $SCRIPTPATH/build-contribs.sh && \
	sh $SCRIPTPATH/build-vlc.sh && \
    sh $SCRIPTPATH/package.sh $VLC_PLATFORM $VLC_CONFIGURATION

terminate 0
