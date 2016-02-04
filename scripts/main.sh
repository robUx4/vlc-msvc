#!/bin/sh

# This assumes we're running in vlc-msvc root folder

# adjust pathes that may have been altered when calling cmd.exe
export ACLOCAL_PATH=`cygpath -p $ACLOCAL_PATH`
export INFOPATH=`cygpath -p $INFOPATH`
export MANPATH=`cygpath -p $MANPATH`

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
    echo "platform: Windows|Metrox86|WindowsPhone"
    echo "configuration: Debug|Release"
    terminate 1
}

case $1 in
    Windows)
        export VLC_PLATFORM=Windows
        export VLC_ABI=winrt
        export VLC_ARCH=arm
        export AS=armasm
        export HAVE_WINDOWSRT=true
        export HAVE_WINSTORE=true
        ;;
    Metrox86)
        export VLC_PLATFORM=Windows
        export VLC_ABI=winrt
        export VLC_ARCH=x86
        export HAVE_WINDOWSRT=true
        export HAVE_WINSTORE=true
        ;;
    WP|WindowsPhone)
        export VLC_PLATFORM=WindowsPhone
        export VLC_ABI=winphone
        export VLC_ARCH=arm
        export AS=armasm
        export HAVE_WINPHONE=true
        export HAVE_WINSTORE=true
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

TESTED_HASH=a7a70e8163e04244d733f4745dc8cbbc7502b830
if [ ! -d $"vlc" ]; then
    echo "VLC source not found, cloning"
    git clone git://git.videolan.org/vlc.git vlc
    cd vlc

    # Just in case, git checkout requires a git username to behave. If none is set, invent one
    git config --get user.email > /dev/null 2&>1 || git config user.email 'windowsrt-build@videolan.org'
    git config --get user.name > /dev/null 2>&1 || git config user.name 'windowsrt build'

    git checkout $TESTED_HASH
    git am -3 ../patches/*.patch
    if [ $? -ne 0 ]; then
        git am --abort
        echo "Applying the patches failed, aborting git-am"
        terminate 1
    fi
else
    echo "VLC source found"
    cd vlc
#    if ! git cat-file -e ${TESTED_HASH}; then
#        cat << EOF
#***
#*** Error: Your vlc checkout does not contain the latest tested commit ***
#***
#
#EOF
#        terminate 1
#    fi
fi

# Run this before playing with our environment, except for the path,
# since we want the tools we already built to be detected
export PATH="$ROOT_FOLDER/vlc/extras/tools/build/bin:$PATH"
sh $SCRIPTPATH/build-tools.sh || terminate 1

# Set required environment variables:
export CC="clwrap"
export CXX="clwrap"
export BUILDCC="`command -v gcc` -std=c99"
export cc=$CC
export cxx=$CXX
export AR="ar"
export NM="dumpbin.exe -symbols"
export LD="ldwrap"
export CCLD="$LD"
export CXXLD="$CCLD"
export RANLIB=true
#export RC=rc.exe
export WINDRES="windres"
export PATH="$ROOT_FOLDER/wrappers:$PATH"
export HAVE_ARMV7A=true
export HAVE_VISUALSTUDIO=true
# Prevent some broken MSYS conversions
# Mind that having a terminal ';' would make empty string a token
# that would be compared against, thus not translating anything
export MSYS2_ARG_CONV_EXCL="/OUT:;-OUT:;-out:;-LIBPATH:;-libpath:"
export BUILD_HOST=$VLC_ARCH-msvc-mingw32$VLC_ABI

# We are now in ROOT_FOLDER/vlc
sh $SCRIPTPATH/build-contribs.sh && \
	sh $SCRIPTPATH/build-vlc.sh && \
    sh $SCRIPTPATH/package.sh $VLC_PLATFORM $VLC_CONFIGURATION

terminate 0
