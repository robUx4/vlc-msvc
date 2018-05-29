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

case $VLC_ABI in
    winrt|winphone)
        D3D11_HEADERS=--enable-d3d11
        ;;
    *)
        D3D11_HEADERS=--disable-d3d11
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
	$OPTIM_MODE $D3D11_HEADERS \
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
	--enable-protobuf \
	--disable-aribb25 \
	--disable-gnuv3 \
	--disable-qtsvg \
	--enable-ssh2 \
	--disable-vncclient \
	--enable-jpeg \
	--disable-postproc \
	--enable-vpx \
	--enable-libdsm \
	--disable-mfx \
	--enable-freetype2 \
	--enable-ffmpeg \
	--enable-flac \
	--enable-fribidi \
	--enable-gsm \
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
	--disable-libplacebo \
	--enable-dvbpsi \
--enable-mpg123 \
--disable-libmpeg2 \
--disable-faad2 \
--disable-x264 \
--disable-x265 \
--disable-srt \
	|| exit 1

# clang
# --disable-flac \
# --disable-vpx \

WIDL="wmidl" CONFIG_SITE=/dev/null USE_FFMPEG=1 WANT_AUTOMAKE=latest WANT_AUTOCONF=latest PKG_CONFIG_PATH="" CC_FOR_BUILD="gcc -std=c99" make -j$(nproc) || exit 1
#~ WIDL="wmidl" CONFIG_SITE=/dev/null USE_FFMPEG=1 WANT_AUTOMAKE=latest WANT_AUTOCONF=latest PKG_CONFIG_PATH="" CC_FOR_BUILD="gcc -std=c99" make V=1 || exit 1
