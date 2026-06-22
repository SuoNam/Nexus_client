#!/bin/bash
# ================================================================
# 在 x86_64 开发机上用 Docker + QEMU 模拟 ARM64 环境构建 .deb
#
# 前提条件（一次性配置，配好后永久生效）：
#   sudo apt-get install -y qemu-user-static binfmt-support
#   docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
#
# 然后运行本脚本：
#   bash scripts/cross_build_docker.sh
# ================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_DIR/build/packages"

echo "══════════════════════════════════════════"
echo " Nexus Qt — Docker ARM64 交叉构建 .deb"
echo "══════════════════════════════════════════"

# 检查 Docker
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ 未找到 Docker，请先安装"
    exit 1
fi

# 检查 QEMU binfmt 注册
if ! docker run --rm --platform linux/arm64 alpine uname -m 2>/dev/null | grep -q aarch64; then
    echo "⚠  ARM64 模拟可能未配置，尝试自动注册..."
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes || true
fi

mkdir -p "$OUTPUT_DIR"

echo "正在启动 ARM64 Ubuntu 容器构建..."
docker run --rm \
    --platform linux/arm64 \
    -v "$PROJECT_DIR":/src \
    -v "$OUTPUT_DIR":/output \
    -w /src \
    ubuntu:22.04 \
    bash -c '
        set -e
        export DEBIAN_FRONTEND=noninteractive

        echo "==> 安装依赖..."
        apt-get update -qq
        apt-get install -y --no-install-recommends \
            cmake g++ \
            qtbase5-dev qtdeclarative5-dev \
            libqt5websockets5-dev libqt5serialport5-dev \
            qml-module-qtquick2 qml-module-qtquick-controls2 \
            qml-module-qt-labs-settings qml-module-qtquick-layouts \
            dpkg-dev 2>&1 | tail -5

        echo "==> 配置..."
        cmake -S /src -B /tmp/build \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX=/usr

        echo "==> 编译（QEMU 模拟下单线程，避免并发 segfault）..."
        cmake --build /tmp/build -j1

        echo "==> 打包..."
        mkdir -p /tmp/build/packages
        cd /tmp/build && cpack -G DEB

        echo "==> 复制包..."
        cp /tmp/build/packages/*.deb /output/
    '

echo ""
echo "══════════════════════════════════════════"
echo " 构建完成！包文件位于："
ls "$OUTPUT_DIR"/*.deb 2>/dev/null && echo ""
echo " 传到 RK3528："
echo "   scp $OUTPUT_DIR/*.deb user@rk3528-ip:~/"
echo ""
echo " 在 RK3528 上安装运行时依赖并安装："
echo "   sudo apt-get install -y \\"
echo "     libqt5quick5 qml-module-qtquick-controls2 \\"
echo "     qml-module-qt-labs-settings qml-module-qtquick-layouts \\"
echo "     libqt5websockets5 libqt5serialport5"
echo "   sudo dpkg -i nexusqt_*.deb"
echo "══════════════════════════════════════════"
