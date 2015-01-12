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

cmd.exe /C "scripts\\setup-env.bat $PLATFORM $CONFIGURATION"

