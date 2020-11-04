#!/bin/bash

INSTALL_GCC()
{
axel -n 8 "https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz"
axel -n 8 "https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz"
tar Jxvf gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz
tar Jxvf gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz
}

BUILD_KERNEL()
{
SH_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
KERNEL_DIR=$1
DEVICE=$2
BUILD_USER=$3
BUILD_HOST=$4
GCC_TYPE1=$5
GCC_TYPE2=$6

cd "$KERNEL_DIR" || exit

make O=out ARCH=arm64 "$DEVICE"
make -j$(nproc --all) O=out \
    ARCH=arm64 \
    KBUILD_BUILD_USER="$BUILD_USER" \
    KBUILD_BUILD_HOST="$BUILD_HOST" \
    CC="$SH_DIR/clang/bin/clang" \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=$SH_DIR/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz/bin/$GCC_TYPE1- \
    CROSS_COMPILE_ARM32=$SH_DIR/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin/$GCC_TYPE2-- \
    LD="$SH_DIR/clang/bin/ld.lld" \
    LLVM_AR="$SH_DIR/clang/bin/llvm-ar" \
    LLVM_NM="$SH_DIR/clang/bin/llvm-nm" \
    OBJCOPY="$SH_DIR/clang/bin/llvm-objcopy" \
    OBJDUMP="$SH_DIR/clang/bin/llvm-objdump" \
    STRIP="$SH_DIR/clang/bin/llvm-strip"

if [ -e "$KERNEL_DIR/out/arch/arm64/boot/Image.gz" ] ;then
    mv $KERNEL_DIR/out/arch/arm64/boot/Image.gz ./
fi
if [ -e "$KERNEL_DIR/out/arch/arm64/boot/Image.gz" ] ;then
    mv $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb ./
fi
echo
echo "Done!"
echo
}

if [ "$1" = "INSTALL_GCC" ] ;then
    INSTALL_GCC
else
    BUILD_KERNEL
fi