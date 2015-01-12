#!/bin/sh

usage()
{
    echo "./build.sh <platform> <configuration>"
    echo "platform: Windows|WindowsPhone"
    echo "configuration: Debug|Release"
}

case $1 in
    Windows)
        PLATFORM=Windows
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
	which $1 > /dev/null 2>&1 || pacman -S --noconfirm $pkg
}

test_package make
test_package dos2unix
test_package cmake mingw-w64-`uname -m`-cmake
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
test_package gcc #required by ffmpeg for gaspp

cmd.exe /C "scripts\\setup-env.bat $PLATFORM $CONFIGURATION"

