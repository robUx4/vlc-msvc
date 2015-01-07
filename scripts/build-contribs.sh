export CC="$HOME/wrappers/windowsrt/clwrap"
export CXX="$CC"
export cc=$CC
export cxx=$CXX
export AR="$HOME/wrappers/arwrap"
export NM="dumpbin.exe"
#export nm=$NM
export AS=armasm
#export as=$AS
export LD="$HOME/wrappers/ldwrap"
export CCLD="$LD"
export CXXLD="$CCLD"
export RANLIB=true
export PATH="$HOME/wrappers:$HOME/vlc/extra/tools/ragel/ragel:$PATH"
export HAVE_ARMV7A=true
export HAVE_VISUALSTUDIO=true
export HAVE_WINDOWSRT=true
#export HAVE_WINPHONE=true
# Prevent some broken MSYS conversions
# Mind that having a terminal ';' would make empty string a token
# that would be compared against, thus not translating anything
export MSYS2_ARG_CONV_EXCL="/OUT:;-OUT:;-out:;-LIBPATH:;-libpath:"

../bootstrap --host=arm-msvc-mingw32winrt --build=x86-w64-mingw32 \
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
    --disable-mpg123

# This was necessary at some point as a package was trying to link to zlib
#make .zlib
make