#!/bin/sh

usage()
{
    echo "./build.sh <platform> <configuration>"
    echo "platform: WindowsPhone|Windows|Metrox86"
    echo "   WindowsPhone: Phone on ARM"
    echo "   Windows:      Desktop on ARM"
    echo "   Metrox86:     Desktop on x86"
    echo "configuration: Debug|Release"
}

case $1 in
    Windows)
        PLATFORM=Windows
        ;;
    Metrox86)
        PLATFORM=Metrox86
        ;;
    WP|WindowsPhone)
        PLATFORM=WindowsPhone
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

$COMSPEC /C "scripts\\setup-env.bat $PLATFORM $CONFIGURATION"
