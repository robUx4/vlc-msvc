#!/bin/sh

usage()
{
    echo "./build.sh <platform> <configuration>"
    echo "platform: WindowsPhone|Windows|Metrox86|Universal86|Universal64|UniversalARM|UniversalARM64"
    echo "   WindowsPhone:   Phone 8.1 on ARM"
    echo "   Windows:        Desktop 8.1 on ARM"
    echo "   Metrox86:       Desktop 8.1 on x86"
    echo "   Metrox64:       Desktop 8.1 on amd64"
    echo "   Universal86:    Universal on x86"
    echo "   Universal64:    Universal on amd64"
    echo "   UniversalARM:   Universal on ARM"
    echo "   UniversalARM64: Universal on ARM64"
    echo "   Win32:          Desktop on x86"
    echo "   Win64:          Desktop on amd64"
    echo "configuration: Debug|Release"
}

case $1 in
    Windows)
        PLATFORM=Windows
        ;;
    Metrox86)
        PLATFORM=Metrox86
        ;;
    Metrox64)
        PLATFORM=Metrox64
        ;;
    Universal86)
        PLATFORM=Universal86
        ;;
    Universal64)
        PLATFORM=Universal64
        ;;
    UniversalARM)
        PLATFORM=UniversalARM
        ;;
    UniversalARM64)
        PLATFORM=UniversalARM64
        ;;
    WP|WindowsPhone)
        PLATFORM=WindowsPhone
        ;;
    Win32)
        PLATFORM=Win32
        ;;
    Win64)
        PLATFORM=Win64
        ;;
    *)
        usage
        exit 1
esac

shift

case $1 in
    Debug)
        CONFIGURATION=Debug
        ;;
    Release)
        CONFIGURATION=Release
        ;;
    *)
        usage
        exit 1
esac

test_package()
{
	if [ "$2" != "" ] ; then
		pkg=$2
	else
		pkg=$1
	fi
	command -v $1 > /dev/null 2>&1 || pacman -S --noconfirm $pkg || echo "you may need to run autorebase.bat" || exit 1
}

case $MSYSTEM in
    MINGW32)
        UNAME=i686
        ;;
    MINGW64)
        UNAME=x86_64
        ;;
esac

test_gcc()
{
    command -v gcc | grep /mingw || pacman -S --noconfirm mingw-w64-$UNAME-gcc
}

test_package make
test_package dos2unix
test_package unzip
test_package pkg-config
test_package autoreconf autoconf
test_package automake
test_package libtool
test_package m4
test_package gettext
test_package svn subversion
test_package tar
test_package patch
test_package git
test_package autogen
test_gcc #required by ffmpeg for gaspp
test_package yasm
test_package nasm
test_package gperf
test_package bison
# tools to avoid building in extra/tools
test_package cmake mingw-w64-$UNAME-cmake-modules
test_package protoc mingw-w64-$UNAME-protobuf
test_package ragel mingw-w64-$UNAME-ragel
test_package widl mingw-w64-$UNAME-tools-git

SCRIPT=`readlink -f "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`
ROOT_FOLDER=$SCRIPTPATH

cd $ROOT_FOLDER

TESTED_HASH=a7a70e8163e04244d733f4745dc8cbbc7502b830
if [ ! -d "vlc" ]; then
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
sh $SCRIPTPATH/scripts/build-tools.sh || terminate 1

cd $SCRIPTPATH

$COMSPEC /C "scripts\\setup-env.bat $PLATFORM $CONFIGURATION"
