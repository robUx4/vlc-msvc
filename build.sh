#!/bin/sh

usage()
{
    echo "./build.sh <platform> <configuration>"
    echo "platform: Windows|Metrox86|WindowsPhone"
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
	command -v $1 > /dev/null 2>&1 || pacman -S --noconfirm $pkg || exit 1
}

test_gcc()
{
    command -v gcc | grep /mingw || pacman -S --noconfirm mingw-w64-`uname -m`-gcc
}

test_package make
test_package dos2unix
test_package cmake mingw-w64-i686-cmake
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

$COMSPEC /C "scripts\\setup-env.bat $PLATFORM $CONFIGURATION"
