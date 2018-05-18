#!/bin/sh

# This assumes we're running in vlc-msvc root folder

# adjust pathes that may have been altered when calling cmd.exe
#export ACLOCAL_PATH=$(wslpath -p $ACLOCAL_PATH)
#export INFOPATH=$(wslpath -p $INFOPATH)
#export MANPATH=$(wslpath -p $MANPATH)

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
    echo "./main.sh <platform> <configuration>"
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
        export WIN32_WINNT=0x603
        export WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
        ;;
    Metrox64)
        export VLC_PLATFORM=Windows
        export VLC_ABI=winrt
        export VLC_ARCH=amd64
        export WIN32_WINNT=0x603
        export WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
        ;;
    Metrox86)
        export VLC_PLATFORM=Windows
        export VLC_ABI=winrt
        export VLC_ARCH=x86
        export WIN32_WINNT=0x603
        export WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
        ;;
    WP|WindowsPhone)
        export VLC_PLATFORM=WindowsPhone
        export VLC_ABI=winphone
        export VLC_ARCH=arm
        export AS=armasm
        export WIN32_WINNT=0x603
        export WINAPI_FAMILY=WINAPI_FAMILY_PHONE_APP
        echo "Make sure you install the Windows SDK for Windows 8.1 from"
        echo "  https://dev.windows.com/en-us/downloads/windows-8-1-sdk"
        echo "And the Windows Driver Kit for Windows 8.1 from"
        echo " https://msdn.microsoft.com/library/windows/hardware/dn249725%28v=vs.85%29.aspx"
        ;;
    Universal86)
        export VLC_PLATFORM=Universal
        export VLC_ABI=uwp
        export VLC_ARCH=x86
        export WIN32_WINNT=0x0A00
        export WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
        ;;
    Universal64)
        export VLC_PLATFORM=Universal
        export VLC_ABI=uwp
        export VLC_ARCH=amd64
        export WIN32_WINNT=0x0A00
        export WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
        ;;
    UniversalARM)
        export VLC_PLATFORM=Universal
        export VLC_ABI=uwp
        export VLC_ARCH=arm
        export AS=armasm
        export WIN32_WINNT=0x0A00
        export WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
        ;;
    UniversalARM64)
        export VLC_PLATFORM=Universal
        export VLC_ABI=uwp
        export VLC_ARCH=aarch64
        export MSVC_ARCH=arm64
        export AS=armasm64
        export WIN32_WINNT=0x0A00
        export WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
        ;;
    Win32)
        export VLC_PLATFORM=Desktop
        export VLC_ABI=desktop
        export VLC_ARCH=x86
        export WIN32_WINNT=0x0A00
        export WINAPI_FAMILY=WINAPI_FAMILY_DESKTOP_APP
        ;;
    Win64)
        export VLC_PLATFORM=Desktop
        export VLC_ABI=desktop
        export VLC_ARCH=amd64
        export WIN32_WINNT=0x0A00
        export WINAPI_FAMILY=WINAPI_FAMILY_DESKTOP_APP
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

if [ "$MSVC_ARCH" = "" ] ; then
    export MSVC_ARCH=$VLC_ARCH
fi

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
ROOT_FOLDER=$SCRIPTPATH/..

cd $ROOT_FOLDER

if [ "$WIN32_WINNT" != "" ] ; then
    CPPFLAGS="$CPPFLAGS -D_WIN32_WINNT=$WIN32_WINNT"
    CFLAGS="$CFLAGS -D_WIN32_WINNT=$WIN32_WINNT"
    CXXFLAGS="$CXXFLAGS -D_WIN32_WINNT=$WIN32_WINNT"
fi

if [ -n $WINAPI_FAMILY ] ; then
    CPPFLAGS="$CPPFLAGS -DWINAPI_FAMILY=$WINAPI_FAMILY"
    CFLAGS="$CFLAGS -DWINAPI_FAMILY=$WINAPI_FAMILY"
    CXXFLAGS="$CXXFLAGS -DWINAPI_FAMILY=$WINAPI_FAMILY"
fi

# Set required environment variables:
export USE_MSCL="1"
export CC="clangwrap"
export CXX="clangwrap"
#~ export BUILDCC="$(command -v gcc) -std=c99"
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
