#!/bin/sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
ROOT_FOLDER=$SCRIPTPATH/../

if [ "$VLC_ABI" = "" ] ; then
    echo "\$VLC_ABI is unset"
    exit 1
fi

if [ "$VLC_ARCH" = "" ] ; then
    echo "\$VLC_ARCH is unset"
    exit 1
fi

if [ "$VLC_CONFIGURATION" = "" ] ; then
    echo "\$VLC_CONFIGURATION is unset"
    exit 1
fi

case $VLC_CONFIGURATION in
    Debug*)
        OPTIM_MODE=--disable-optim
        ;;
    Release*)
        OPTIM_MODE=
        ;;
esac

BUILD_FOLDER=${ROOT_FOLDER}vlc/contrib/${ABI_VARIANT}/
if [ ! -d $BUILD_FOLDER ]; then
    mkdir $BUILD_FOLDER
fi
cd $BUILD_FOLDER

../bootstrap --host=$BUILD_HOST --build=x86-w64-mingw32 \
	--prefix="${ROOT_FOLDER}vlc/contrib/${BUILD_VARIANT}" \
	$OPTIM_MODE \
	--disable-gnuv3 \
	--disable-sout \
	--enable-ffmpeg \
	--enable-flac \
	--disable-fontconfig \
	--enable-freetype2 \
	--enable-fribidi \
	--enable-gsm \
	--enable-iconv \
	--enable-ass \
	--enable-dca \
	--disable-dvbpsi \
	--enable-ebml \
	--enable-matroska \
	--enable-ogg \
	--enable-harfbuzz \
	--enable-vorbis \
	--enable-libxml2 \
	--enable-openjpeg \
	--enable-vpx \
	--enable-jpeg \
	--enable-opus \
	--enable-speex \
	--enable-speexdsp \
	--enable-zlib \
	--disable-caca \
	--disable-directx \
	--disable-chromaprint \
	--disable-gettext \
	--enable-gme \
	--enable-gnutls \
    --enable-ssh2 \
	--enable-nettle \
	--disable-goom \
	--disable-projectM \
	--disable-qt \
	--disable-qtsvg \
	--disable-schroedinger \
	--enable-theora \
	--disable-vncclient \
	--disable-zvbi \
    --disable-aribb25 \
	--disable-a52 \
    --enable-samplerate \
    --enable-upnp \
    --disable-postproc \
    --disable-sdl \
    --disable-SDL_image \
	--enable-modplug \
    --disable-disc \
    --enable-lua \
    --enable-luac \
    --disable-protobuf \
    --disable-protoc \
	--disable-dshow \
	--enable-libarchive \
	--enable-nfs \
	--enable-microdns \
	--enable-libdsm \
	--disable-mfx \
    --enable-sidplay2 \
--disable-mpg123 \
--disable-libmpeg2 \
	|| exit 1

# clang
# --disable-flac \
# --disable-vpx \

WIDL="wmidl" USE_FFMPEG=1 CC_FOR_BUILD="gcc -std=c99" make -j`nproc` || exit 1
#~ WIDL="wmidl" USE_FFMPEG=1 CC_FOR_BUILD="gcc -std=c99" make V=1 || exit 1
