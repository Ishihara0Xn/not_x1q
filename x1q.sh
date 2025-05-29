#!/bin/bash

# Set paths and variables
BASE_DIR="$(pwd)"
OUT_DIR="$BASE_DIR/out"
ANYKERNEL_DIR="$BASE_DIR/AnyKernel3/x1q"
IMAGE_PATH="$OUT_DIR/arch/arm64/boot/Image"
DTBO_PATH="$OUT_DIR/arch/arm64/boot/dtbo.img"
DTB_DIR="$OUT_DIR/arch/arm64/boot/dts/vendor/qcom"
KERNEL_NAME="not_kernel-"

# Install dependencies
sudo apt-get update && sudo apt-get install -y \
    clang-format clang-tidy clang-tools clang clangd \
    libc++-dev libc++1 libc++abi-dev libc++abi1 \
    libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev \
    libomp-dev libomp5 lld lldb llvm-dev llvm-runtime \
    llvm python3-clang gcc-aarch64-linux-gnu bc git make

# Clone Proton Clang if not exists
if [ ! -d "proton-clang" ]; then
    git clone https://gitlab.com/LeCmnGend/clang.git -b clang-18 --depth=1 proton-clang
fi

# Set up toolchain
TC_DIR="$BASE_DIR/proton-clang"
export PATH="$TC_DIR/bin:$PATH"
export CONFIG_NO_ERROR_ON_MISMATCH=y
export CONFIG_DEBUG_SECTION_MISMATCH=y
export KBUILD_BUILD_USER="SudoMohamed"
export KBUILD_BUILD_HOST="🌱"

# Clean previous builds
rm -rf "$IMAGE_PATH" "$DTBO_PATH" .version .local
rm -rf "$ANYKERNEL_DIR/dtb"
mkdir -p "$OUT_DIR" "$ANYKERNEL_DIR"

# Build configuration
DEFCONFIG="vendor/kona-not_defconfig vendor/samsung/x1q.config vendor/debugfs.config"
make O="$OUT_DIR" CC=clang ARCH=arm64 $DEFCONFIG

echo "*****************************************"
echo "** STARTING KERNEL BUILD               **"
echo "*****************************************"

# Build kernel
make -j$(nproc) O="$OUT_DIR" \
    KCFLAGS=-w \
    ARCH=arm64 \
    CC=clang \
    AR=llvm-ar \
    NM=llvm-nm \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    DTC_EXT="$BASE_DIR/tools/dtc" \
    CONFIG_BUILD_ARM64_DT_OVERLAY=y


echo "✅ The bomb has been planted."
