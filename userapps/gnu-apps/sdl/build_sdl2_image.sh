#!/bin/bash

# Get initial variables
BUILD_CONF="../conf.sh"
if [ ! -f ${BUILD_CONF} ]; then
  echo "conf.sh file not exist!"
  exit 1;
fi
source ${BUILD_CONF} $1

APP_NAME="SDL2_image"
VERSION="2.0.5"
APP_DIR=${APP_NAME}-${VERSION}

# Check zlib exist
LIB_DIR=${ROOTDIR}/sdk/lib
INC_DIR=${ROOTDIR}/sdk/include

if [ ! -f ${LIB_DIR}/libSDL2.a ] || [ ! -f ${LIB_DIR}/libpng16.a ] || [ ! -f ${LIB_DIR}/libz.a ]; then
        echo "========= Error: not find sdl or libpng or zlib, please build them first! ========="
        exit 1;
fi

RT_DIR=${ROOTDIR}/sdk/rt-thread
RT_INC=" -I. -I${RT_DIR}/include -I${RT_DIR}/components/dfs -I${RT_DIR}/components/drivers -I${RT_DIR}/components/finsh -I${RT_DIR}/components/net -I${INC_DIR} -I${INC_DIR}/sdl"

export LDFLAGS="$CFLAGS -T ${ROOTDIR}/linker_scripts/arm/cortex-a/link.lds -march=armv7-a -marm -msoft-float -L${RT_DIR}/lib -L${LIB_DIR} -Wl,--whole-archive -lrtthread -Wl,--no-whole-archive -n -static -Wl,--start-group -lrtthread -Wl,--end-group"

CFLAGS+=${RT_INC}
export CFLAGS

TagFile=".patched"
DbgFile=".dbg_patched"

function usage() {
  echo "====================="
  echo "Usage: $0 [options] [verbose]"
  echo ""
  echo "  $0 - build without debug info and strip, if build option not same with the exist source dir, backup and re-unzip"
  echo "  $0 verbose - default build with detail log"
  echo "  $0 debug - build with debug info and not strip, if build option not same with the exist source dir, backup and re-unzip"
  echo "  $0 debug verbose - debug build with detail log"
  echo "  $0 help - show help info"
  echo "====================="
}

# create tag file and do patch if has
function dopatch() {
    if [ "$1" == "debug" ]; then
        touch "$DbgFile"
    else
        touch "$TagFile"
    fi
}

function preparesrc() {
    if [ ! -f ${APP_DIR}.tar.gz ]; then
        echo "========= Downloading ${APP_DIR}.tar.gz ========="
	wget https://www.libsdl.org/projects/SDL_image/release/${APP_DIR}.tar.gz
    fi
    tar xf ${APP_DIR}.tar.gz
    cd ${APP_DIR}
}

# debug build
function builddbg() {
    if [ -d ${APP_DIR} ] && [ -f ${APP_DIR}/${DbgFile} ]; then
        cd ${APP_DIR}
    else
        if [ -d ${APP_DIR} ]; then
            # bank old source dir, default build
            mv ${APP_DIR} ${APP_DIR}.$(date "+%Y%m%d%H%M%S")
        fi
        preparesrc
        dopatch $1
    fi

    ./configure \
	--prefix=${ROOTDIR}/build \
	--target=${CROSS_COMPILE} \
	--host=${CROSS_COMPILE} \
	--build=i686-pc-linux-gnu \
	--enable-static
    # remove "/usr/include/libpng16" and "/usr/include/SDL2"
    sed -i 's/\/usr\/include\/libpng16/./g' Makefile
    sed -i 's/\/usr\/include\/SDL2/./g' Makefile
    # disable building showimage
    sed -i 's/Makefile\ $(PROGRAMS)/Makefile/g' Makefile
    make clean
    if [ "$2" == "verbose" ]; then
        make V=1
    else
        make
    fi
}

# default build
function builddef() {
    if [ -d ${APP_DIR} ] && [ -f ${APP_DIR}/${TagFile} ]; then
        cd ${APP_DIR}
    else
        if [ -d ${APP_DIR} ]; then
            # bank old source dir, debug build
            mv ${APP_DIR} ${APP_DIR}.$(date "+%Y%m%d%H%M%S").dbg
        fi
        preparesrc
        dopatch
    fi

    ./configure \
	--prefix=${ROOTDIR}/build \
	--target=${CROSS_COMPILE} \
	--host=${CROSS_COMPILE} \
	--build=i686-pc-linux-gnu \
	--enable-static
    # remove "/usr/include/libpng16" and "/usr/include/SDL2"
    sed -i 's/\/usr\/include\/libpng16/./g' Makefile
    sed -i 's/\/usr\/include\/SDL2/./g' Makefile
    # disable building showimage
    sed -i 's/Makefile\ $(PROGRAMS)/Makefile/g' Makefile
    make clean
    if [ "$1" == "verbose" ]; then
        make V=1
    else
        make
    fi
    # strip
    #arm-linux-musleabi-strip xx
}


if [ "$1" == "help" ]; then
    usage
    exit 0
elif [ "$1" == "debug" ]; then
    builddbg $1 $2
else
    builddef $1
fi


echo "========= Copy lib and headers ========="
test -d ${ROOTDIR}/sdk/include/sdl || mkdir -p ${ROOTDIR}/sdk/include/sdl
test -d ${ROOTDIR}/sdk/lib || mkdir -p ${ROOTDIR}/sdk/lib
rm -rf ${ROOTDIR}/sdk/include/sdl/SDL_image.h
rm -rf ${ROOTDIR}/sdk/lib/libSDL2_image.a

cp SDL_image.h ${ROOTDIR}/sdk/include/sdl
cp .libs/libSDL2_image.a ${ROOTDIR}/sdk/lib

echo "========= SDL2-image building finished. ========="
