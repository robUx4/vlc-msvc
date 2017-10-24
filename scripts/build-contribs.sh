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

export PKG_CONFIG_PATH=${ROOT_FOLDER}vlc/contrib/${BUILD_VARIANT}/lib/pkgconfig
export PKG_CONFIG_LIBDIR=$PKG_CONFIG_PATH

../bootstrap --host=$BUILD_HOST --build=x86-w64-mingw32 \
	--prefix="${ROOT_FOLDER}vlc/contrib/${BUILD_VARIANT}" \
	$OPTIM_MODE \
	--disable-sdl \
	--disable-schroedinger \
	--disable-vncserver \
	--disable-chromaprint \
	--enable-modplug \
	--disable-SDL_image \
	--disable-fontconfig \
	--disable-zvbi \
	--disable-caca \
	--disable-gettext \
	--enable-gme \
	--enable-vorbis \
	--enable-sidplay2 \
	--enable-samplerate \
	--enable-iconv \
	--disable-goom \
	--enable-dca \
	--disable-projectM \
	--enable-ass \
	--disable-qt \
	--disable-qtsvg \
	--disable-protobuf \
	--disable-aribb25 \
	--disable-gnuv3 \
	--enable-ssh2 \
	--disable-vncclient \
	--enable-jpeg \
	--disable-postproc \
	--enable-vpx \
	--enable-libdsm \
	--disable-mfx \
	--enable-freetype2 \
	--disable-sout \
	--enable-ffmpeg \
	--enable-flac \
	--enable-fribidi \
	--enable-gsm \
	--disable-dvbpsi \
	--enable-ebml \
	--enable-matroska \
	--enable-ogg \
	--enable-harfbuzz \
	--enable-libxml2 \
	--enable-openjpeg \
	--enable-opus \
	--enable-speex \
	--enable-speexdsp \
	--enable-zlib \
	--disable-directx \
	--enable-gnutls \
	--enable-nettle \
	--enable-theora \
	--disable-a52 \
    --enable-upnp \
    --disable-disc \
    --enable-lua \
    --enable-luac \
    --disable-protoc \
	--disable-dshow \
	--enable-libarchive \
	--enable-nfs \
	--enable-microdns \
--disable-mpg123 \
--disable-libmpeg2 \
	|| exit 1

# clang
# --disable-flac \
# --disable-vpx \

WIDL="wmidl" USE_FFMPEG=1 CC_FOR_BUILD="gcc -std=c99" make -j`nproc` || exit 1
#~ WIDL="wmidl" USE_FFMPEG=1 CC_FOR_BUILD="gcc -std=c99" make V=1 || exit 1
