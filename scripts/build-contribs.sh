#!/bin/sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
ROOT_FOLDER=$SCRIPTPATH/../
cd $ROOT_FOLDER/vlc/contrib

if [ ! -d $PLATFORM ] ; then
    mkdir $PLATFORM
fi

cd $PLATFORM

../bootstrap --host=$BUILD_HOST --build=x86-w64-mingw32 \
	--disable-gpl \
	--disable-sout \
	--enable-ffmpeg \
	--disable-flac \
	--disable-fontconfig \
	--enable-freetype2 \
	--enable-fribidi \
	--enable-gsm \
	--enable-iconv \
	--disable-ass \
	--enable-dca \
	--enable-dvbpsi \
	--enable-ebml \
	--enable-matroska \
	--enable-ogg \
    --disable-harfbuzz \
	--enable-vorbis \
	--enable-libxml2 \
	--enable-openjpeg \
	--enable-opus \
	--enable-speex \
	--enable-speexdsp \
	--enable-zlib \
	--disable-dvdread \
	--disable-dvdnav \
	--disable-caca \
	--disable-directx \
	--disable-chromaprint \
	--disable-gettext \
	--disable-gme \
	--disable-gmp \
	--disable-libgpg-error \
    --disable-net \
    --disable-sout \
	--disable-gnutls \
    --disable-gcrypt \
    --disable-ssh2 \
    --disable-upnp \
	--disable-nettle \
	--disable-goom \
	--enable-dca \
	--disable-mad \
	--disable-projectM \
	--disable-pthreads \
	--disable-qt \
	--disable-schroedinger \
	--disable-theora \
	--disable-vncserver \
	--disable-zvbi \
	--disable-sdl \
	--disable-aribb24 \
    --disable-aribb25 \
	--enable-a52 \
    --enable-samplerate \
    --disable-upnp \
    --disable-postproc \
    --disable-sdl \
    --disable-SDL_image \
    --disable-modplug \
    --disable-disc \
    --disable-lua \
    --disable-protobuf \
    --disable-mpg123 \
	|| exit 1

make -j`nproc` || exit 1