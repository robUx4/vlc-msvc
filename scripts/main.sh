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
    echo "platform: Windows|Metrox86|Metrox64|WindowsPhone|Universal86|Universal64|UniversalARM|UniversalARM64|Win32|Win64"
    echo "configuration: Debug|Release"
    terminate 1
}

case $1 in
    Windows)
        export VLC_PLATFORM=Windows
        export VLC_ABI=winrt
        export VLC_ARCH=arm
        export AS=armasm
        ;;
    Metrox64)
        export VLC_PLATFORM=Windows
        export VLC_ABI=winrt
        export VLC_ARCH=amd64
        ;;
    Metrox86)
        export VLC_PLATFORM=Windows
        export VLC_ABI=winrt
        export VLC_ARCH=x86
        ;;
    WP|WindowsPhone)
        export VLC_PLATFORM=WindowsPhone
        export VLC_ABI=winphone
        export VLC_ARCH=arm
        export AS=armasm
        echo "Make sure you install the Windows SDK for Windows 8.1 from"
        echo "  https://dev.windows.com/en-us/downloads/windows-8-1-sdk"
        echo "And the Windows Driver Kit for Windows 8.1 from"
        echo " https://msdn.microsoft.com/library/windows/hardware/dn249725%28v=vs.85%29.aspx"
        ;;
    Universal86)
        export VLC_PLATFORM=Universal
        export VLC_ABI=uwp
        export VLC_ARCH=x86
        ;;
    Universal64)
        export VLC_PLATFORM=Universal
        export VLC_ABI=uwp
        export VLC_ARCH=amd64
        ;;
    UniversalARM)
        export VLC_PLATFORM=Universal
        export VLC_ABI=uwp
        export VLC_ARCH=arm
        export AS=armasm
        ;;
    UniversalARM64)
        export VLC_PLATFORM=Universal
        export VLC_ABI=uwp
        export VLC_ARCH=armv8
        export AS=armasm64
        ;;
    Win32)
        export VLC_PLATFORM=Desktop
        export VLC_ABI=desktop
        export VLC_ARCH=x86
        ;;
    Win64)
        export VLC_PLATFORM=Desktop
        export VLC_ABI=desktop
        export VLC_ARCH=amd64
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

if [ "$WIN32_WINNT" != "" ] ; then
    CPPFLAGS="$CPPFLAGS -D_WIN32_WINNT=$WIN32_WINNT"
    CFLAGS="$CFLAGS -D_WIN32_WINNT=$WIN32_WINNT"
    CXXFLAGS="$CXXFLAGS -D_WIN32_WINNT=$WIN32_WINNT"
fi

if [ "$WINAPI_FAMILY" != "" ] ; then
    CPPFLAGS="$CPPFLAGS -DWINAPI_FAMILY=$WINAPI_FAMILY"
    CFLAGS="$CFLAGS -DWINAPI_FAMILY=$WINAPI_FAMILY"
    CXXFLAGS="$CXXFLAGS -DWINAPI_FAMILY=$WINAPI_FAMILY"
fi

# Set required environment variables:
export USE_MSCL="1"
export CC="clangwrap"
export CXX="clangwrap"
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
export CPPFLAGS="$CPPFLAGS"
export CFLAGS="$CFLAGS"
export CXXFLAGS="$CXXFLAGS"
# export HAVE_ARMV7A=true
export HAVE_VISUALSTUDIO=true
# Prevent some broken MSYS conversions
# Mind that having a terminal ';' would make empty string a token
# that would be compared against, thus not translating anything
export MSYS2_ARG_CONV_EXCL="/OUT:;-OUT:;-out:;-LIBPATH:;-libpath:"
export BUILD_HOST=$VLC_ARCH-msvc-mingw32$VLC_ABI
export BUILD_VARIANT=${BUILD_HOST}_${VLC_CONFIGURATION}
export ABI_VARIANT=${VLC_ABI}_${VLC_ARCH}_${VLC_CONFIGURATION}

# We are now in ROOT_FOLDER/vlc
sh $SCRIPTPATH/build-contribs.sh && \
	sh $SCRIPTPATH/build-vlc.sh && \
    sh $SCRIPTPATH/package.sh $VLC_PLATFORM $VLC_CONFIGURATION

terminate 0
