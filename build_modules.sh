#!/bin/bash

set -e

if [[ "$1" == "-h" ]]; then
    echo "$0 [JetPack_version]"
    echo "$0 -h"
    exit 1
fi

export DEVDIR=$(cd `dirname $0` && pwd)

. $DEVDIR/scripts/setup-common "$1"

SRCS="$DEVDIR/sources_$JETPACK_VERSION"

if [[ "$JETPACK_VERSION" == "5.1.1" ]]; then
    # export CROSS_COMPILE=$DEVDIR/l4t-gcc/$JETPACK_VERSION/bin/aarch64-buildroot-linux-gnu-
    # OPTIONAL: set if using external toolchain (linaro, etc). Must match toolchain used to compile kernel
    TOOLCHAIN_PATH="$DEVDIR/l4t-gcc/$JETPACK_VERSION/bin/"
    # Cross-compiler prefix
    CROSS_PREFIX="aarch64-buildroot-linux-gnu-"
    # Path to display driver sources
    DRIVER_SOURCE_DIR="$SRCS/tegra/kernel-src/nv-kernel-display-driver/NVIDIA-kernel-module-source-TempVersion"
    # Full path to kernel sources dir
    KERNEL_SOURCES_DIR="$SRCS/$KERNEL_DIR"
else
    echo "Warning! Wrong jetpack! No dislay modules will be build"
    exit 1
fi

export LOCALVERSION=-d457
export TEGRA_KERNEL_OUT=$DEVDIR/images/$JETPACK_VERSION
mkdir -p $TEGRA_KERNEL_OUT
export KERNEL_MODULES_OUT=$TEGRA_KERNEL_OUT/modules/extra/opensrc-disp/
mkdir -p $KERNEL_MODULES_OUT

# sets up toolchain path if building with other toolchain.
if [ -n "$TOOLCHAIN_PATH" ]; then
     export PATH="${PATH}:${TOOLCHAIN_PATH}"
fi

make -C "$DRIVER_SOURCE_DIR" modules -j $(nproc --ignore=2) TARGET_ARCH=aarch64 ARCH=arm64 O=$TEGRA_KERNEL_OUT CC="${CROSS_PREFIX}gcc" \
LD="${CROSS_PREFIX}ld" AR="${CROSS_PREFIX}ar" CXX="${CROSS_PREFIX}g++" OBJCOPY="${CROSS_PREFIX}objcopy" \
SYSOUT="$TEGRA_KERNEL_OUT" SYSSRC="$KERNEL_SOURCES_DIR"

echo "Drivers for display are build."
echo "Now you need to copy them manually to jetson"
echo "dest dir is /lib/modules/5.10.104-d457/extra/opensrc-disp/"
echo "List of modules:"
ls $DRIVER_SOURCE_DIR/kernel-open/*.ko 