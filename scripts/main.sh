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
    echo "platform: Windows|WindowsPhone"
    echo "configuration: Debug|Release"
    terminate 1
}

case $1 in
    Windows)
        export VLC_PLATFORM=Windows
	export VLC_ARCH=x86
        ;;
    WP|WindowsPhone)
        export VLC_PLATFORM=WindowsPhone
	export VLC_ARCH=ARM
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

TESTED_HASH=b3746a0973de7b8bea4b881390397aa17cc1f510
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
    if ! git cat-file -e ${TESTED_HASH}; then
        cat << EOF
***
*** Error: Your vlc checkout does not contain the latest tested commit ***
***

EOF
        terminate 1
    fi
fi

# Set required environment variables:
export PATH="$ROOT_FOLDER/vlc/extras/tools/build/bin:$PATH"
#export CC="$ROOT_FOLDER/wrappers/clwrap"
export CC="$ROOT_FOLDER/wrappers/clwrap"
export CXX="$ROOT_FOLDER/wrappers/clwrap"
#export CC="cl"
#export CXX="cl"
#export CPP="$CC -E"
export cc=$CC
export cxx=$CXX
export AR="$ROOT_FOLDER/wrappers/ar"
export NM="dumpbin.exe -symbols"
#export AS=armasm
export LD="$ROOT_FOLDER/wrappers/ldwrap"
#export LD="link"
#export LD="link"
export CCLD="$LD"
export CXXLD="$CCLD"
export RANLIB=true
#export RC=rc.exe
export WINDRES="$ROOT_FOLDER/wrappers/windres"
export PATH="$ROOT_FOLDER/wrappers:$PATH"
#export LDFLAGS="$LDFLAGS -link \"kernel32.lib\" \"runtimeobject.lib\""
#export LDFLAGS="$LDFLAGS TODO.lib"
#export LDFLAGS="kernel32.lib runtimeobject.lib"
#export CPPFLAGS="$CPPFLAGS -nologo -MD -EHsc -FI \"`cygpath $ROOT_FOLDER/headers/fixup.h`\" -D_USE_MATH_DEFINES -DWIN32 -D_WIN32_WINNT=0x603 -DUNICODE -D_UNICODE -D_CRT_SECURE_NO_WARNINGS -DNOMINMAX"
export CPPFLAGS="$CPPFLAGS -DWIN32 -D_WIN32_WINNT=0x603 -DUNICODE -D_UNICODE"
#export CPPFLAGS="$CPPFLAGS -MD -FI \"`cygpath $ROOT_FOLDER/headers/fixup.h`\" -FI \"`cygpath $ROOT_FOLDER/headers/winstorecompat.h`\"   -D_USE_MATH_DEFINES -DWIN32 -D_WIN32_WINNT=0x603 -DFORCE_WINSTORECOMPAT -DUNICODE -D_UNICODE -D_CRT_SECURE_NO_WARNINGS -DNOMINMAX -lkernel32 -lruntimeobject"
#export CPPFLAGS="$CPPFLAGS -link kernel32.lib runtimeobject.lib"
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
    export BUILD_HOST=x86-msvc-mingw32winrt
fi

# We are now in ROOT_FOLDER/vlc
sh $SCRIPTPATH/build-contribs.sh && \
	sh $SCRIPTPATH/build-vlc.sh && \
    sh $SCRIPTPATH/package.sh $VLC_PLATFORM $VLC_CONFIGURATION

terminate 0
