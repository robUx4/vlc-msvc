#!/bin/sh

usage()
{
    echo "./build.sh <platform> <configuration>"
    echo "platform: WindowsPhone|Windows|Metrox86|Universal86|Universal64|UniversalARM|UniversalARM64"
    echo "   WindowsPhone:   Phone 8.1 on ARM"
    echo "   Windows:        Desktop 8.1 on ARM"
    echo "   Metrox86:       Desktop 8.1 on x86"
    echo "   Universal86:    Universal on x86"
    echo "   Universal64:    Universal on amd64"
    echo "   UniversalARM:   Universal on ARM"
    echo "   UniversalARM64: Universal on ARM64"
    echo "   Win32:          Desktop on x86"
    echo "configuration: Debug|Release"
}

case $1 in
    Windows)
        PLATFORM=Windows
        ;;
    Metrox86)
        PLATFORM=Metrox86
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
test_package cmake mingw-w64-$UNAME-cmake
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
test_package cvs
test_package autogen
test_gcc #required by ffmpeg for gaspp
test_package protoc mingw-w64-$UNAME-protobuf
test_package ragel mingw-w64-$UNAME-ragel
test_package yasm

$COMSPEC /C "scripts\\setup-env.bat $PLATFORM $CONFIGURATION"
