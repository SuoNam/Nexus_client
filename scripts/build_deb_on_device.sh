#!/bin/bash
# ================================================================
# 在 RK3528（或任何 ARM64 Debian/Ubuntu 设备）上直接构建 .deb
# 使用方法：
#   1. scp -r Nexus_qt/Nexus_qt user@rk3528-ip:~/NexusQt
#   2. ssh user@rk3528-ip
#   3. cd ~/NexusQt && bash scripts/build_deb_on_device.sh
# ================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"

echo "══════════════════════════════════════════"
echo " Nexus Qt — 在设备上构建 .deb"
echo " 项目目录: $PROJECT_DIR"
echo "══════════════════════════════════════════"

# ── 1. 安装构建依赖 ────────────────────────────────────────────
echo "[1/4] 安装构建依赖..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
    cmake \
    g++ \
    qtbase5-dev \
    qtdeclarative5-dev \
    libqt5websockets5-dev \
    libqt5serialport5-dev \
    qml-module-qtquick2 \
    qml-module-qtquick-controls2 \
    qml-module-qt-labs-settings \
    qml-module-qtquick-layouts \
    dpkg-dev

echo "[1/4] 完成"

# ── 2. 配置 CMake ─────────────────────────────────────────────
echo "[2/4] 配置 CMake..."
cmake -S "$PROJECT_DIR" -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr

echo "[2/4] 完成"

# ── 3. 编译 ───────────────────────────────────────────────────
echo "[3/4] 编译（使用 $(nproc) 核心）..."
cmake --build "$BUILD_DIR" --parallel "$(nproc)"
echo "[3/4] 完成"

# ── 4. 打包 .deb ──────────────────────────────────────────────
echo "[4/4] 生成 .deb 包..."
mkdir -p "$BUILD_DIR/packages"
cd "$BUILD_DIR"
cpack -G DEB

echo ""
echo "══════════════════════════════════════════"
echo " 构建完成！"
DEB_FILE=$(ls "$BUILD_DIR/packages/"*.deb 2>/dev/null | head -1)
if [ -n "$DEB_FILE" ]; then
    echo " 包文件: $DEB_FILE"
    echo ""
    echo " 安装命令:"
    echo "   sudo dpkg -i $DEB_FILE"
    echo ""
    echo " 卸载命令:"
    echo "   sudo dpkg -r nexusqt"
fi
echo "══════════════════════════════════════════"
