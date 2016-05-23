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
    Debug)
        OPTIM_MODE=--disable-optim
        ;;
    Release)
        OPTIM_MODE=
        ;;
esac

BUILD_FOLDER=${ROOT_FOLDER}vlc/contrib/${VLC_ABI}_${VLC_ARCH}_${VLC_CONFIGURATION}/
if [ ! -d $BUILD_FOLDER ]; then
    mkdir $BUILD_FOLDER
fi
cd $BUILD_FOLDER

../bootstrap --host=$BUILD_HOST --build=x86-w64-mingw32 \
	--prefix="${ROOT_FOLDER}vlc/contrib/${BUILD_HOST}_${VLC_CONFIGURATION}" \
	$OPTIM_MODE \
	--disable-gpl \
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
	--enable-dvbpsi \
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
	--disable-gme \
	--disable-gmp \
	--disable-libgpg-error \
	--enable-gnutls \
    --disable-gcrypt \
    --disable-ssh2 \
	--enable-nettle \
	--disable-goom \
	--disable-projectM \
	--disable-pthreads \
	--disable-qt \
	--disable-schroedinger \
	--enable-theora \
	--disable-vncclient \
	--disable-zvbi \
	--disable-sdl \
    --disable-aribb25 \
	--enable-a52 \
    --enable-samplerate \
    --disable-upnp \
    --disable-postproc \
    --disable-sdl \
    --disable-SDL_image \
	--enable-modplug \
    --disable-disc \
    --enable-lua \
    --disable-protobuf \
	--disable-d3d11 \
	--disable-dshow \
	--disable-libarchive \
	--disable-nfs \
	--disable-microdns \
	|| exit 1

USE_FFMPEG=1 make -j`nproc` || exit 1
#USE_FFMPEG=1 make V=1 || exit 1
