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

SRC_FOLDER=${ROOT_FOLDER}vlc/
BUILD_FOLDER=${ROOT_FOLDER}vlc/${ABI_VARIANT}/
if [ ! -d $BUILD_FOLDER ]; then
    mkdir $BUILD_FOLDER
fi
cd $BUILD_FOLDER

if [ ! -f ${SRC_FOLDER}configure ] || [ "${SRC_FOLDER}configure" -ot "${SRC_FOLDER}configure.ac" ] ; then
    echo "Bootstraping..."
    dos2unix ${SRC_FOLDER}configure.ac
    ${SRC_FOLDER}bootstrap || exit 1
fi

case $VLC_CONFIGURATION in
    Debug*)
        DEBUG_MODE=--enable-debug
        ;;
    Release*)
        DEBUG_MODE=--disable-debug
        ;;
esac

if [ "$VisualStudioVersion" == "14.0" ] ; then
    HAS_TIMESPEC=yes
else
    HAS_TIMESPEC=no
fi

if [ ! -f ${BUILD_FOLDER}Makefile ] || [ ${BUILD_FOLDER}Makefile -ot ${SRC_FOLDER}configure.ac ] ; then
    echo "Running configure..."
    export PKG_CONFIG_PATH=${SRC_FOLDER}contrib/${BUILD_VARIANT}/lib/pkgconfig
    export PKG_CONFIG_LIBDIR=$PKG_CONFIG_PATH
    #Lua is compiled fine, but configure.ac tries to run luac while checking for it... since it's an arm binary...
    ac_cv_func_getenv=yes ac_cv_func_putenv=yes ac_cv_func_getpid=yes ac_cv_func_strdup=yes ac_cv_have_decl_strdup=yes \
    ac_cv_func_strnlen=yes ac_cv_have_decl_strnlen=yes ac_cv_func_timespec_get=$HAS_TIMESPEC  ac_cv_func_lldiv=yes ac_cv_func_if_nametoindex=no \
    ac_cv_func_stricmp=yes ac_cv_func_strnicmp=yes ac_cv_func_atof=yes ac_cv_func_atoll=yes ac_cv_func_strtof=yes ac_cv_func_strtoll=yes ac_cv_func_swab=yes \
    ac_cv_c_restrict=restrict ac_cv_c_compiler_gnu=no ac_cv_header_d3d11_h=yes ac_cv_type_ID3D11VideoDecoder=yes ac_cv_header_dxva2api_h=yes ac_cv_host=$BUILD_HOST \
    $SCRIPTPATH/../vlc/configure \
        --host=$BUILD_HOST \
        --build=x86-w64-mingw32 \
        --with-contrib="${SRC_FOLDER}contrib/${BUILD_VARIANT}" \
        --prefix="${BUILD_FOLDER}_win32" \
        --enable-optimize-memory \
        $DEBUG_MODE \
        --enable-winstore-app \
        --disable-vlc \
        --enable-lua \
        --enable-mad \
        --enable-mfx \
        --enable-chromecast \
        --disable-vlm --enable-sout \
        --disable-faad \
        --enable-theora \
        --enable-avcodec --enable-merge-ffmpeg \
        --enable-dca \
        --enable-mpc \
        --enable-libass \
        --disable-x264 \
        --enable-realrtsp \
        --enable-shout \
        --disable-goom \
        --disable-caca \
        --disable-qt \
        --disable-skins2 \
        --enable-sse --enable-mmx \
        --disable-libcddb \
        --disable-zvbi --disable-telx \
        --disable-a52 \
        --enable-dsm \
        --disable-smbclient \
        --disable-vcd \
        --disable-crystalhd \
        --disable-dxva2 \
        --enable-flac \
        --enable-jpeg \
        --enable-vpx \
        --disable-postproc \
        --enable-gme \
        --enable-sidplay2 \
        --enable-live555 \
        --disable-x265 \
        || exit 1
    # Force libtool to generate what we want
    sed -i 's/libname_spec=\"\\$name\"/libname_spec=\"lib\\$name\"/' libtool
    sed -i 's/library_names_spec=\"\\$libname.dll.lib\"/library_names_spec=\"\\$libname.lib\"/' libtool
    sed -i 's/$libname.dll.lib/$library_names_spec/g' libtool
fi

# clang
# --disable-vpx \
# --disable-flac \
# --disable-neon \

echo "Lauching build"
make -j`nproc` || exit 1
#~ make V=1 || exit 1
