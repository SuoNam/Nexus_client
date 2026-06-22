# NexusQt

NexusQt 是 [Nexus](https://github.com/SuoNam/Nexus) 系统的客户端实现版本。它是一个基于 Qt5/QML 开发的系统监控大屏应用，专为 RK3528 等 ARM64 嵌入式 Linux 盒子设计，提供炫酷的 UI 界面和本地化数据采集功能。

## ✨ 特性

- **🖥 系统监控 (SystemMonitor)**：在设备本地实时采集 CPU 使用率、内存占用、网络上下行速度等核心指标。
- **🌤 天气预报 (WeatherModel)**：直接调用和集成 QWeather API，实时显示天气状况。
- **🔌 串口唤醒 (WakeClient)**：支持通过串口发送信号唤醒目标设备。若未启用串口模块，则提供 `QProcess` 兜底方案。
- **🎨 现代化 UI**：采用 Qt Quick (QML) 构建，支持触摸滑动、键盘控制、并自带流畅的页面切换动画和深色模式视觉效果。
- **⚡ 纯本地运行**：各项核心功能均在客户端本地采集并计算，不强依赖外部服务器（天气 API 除外）。
- **📦 便捷打包**：集成了 CPack，可以一键打包为 `.deb` 格式，方便在 Debian/Ubuntu ARM64 系统上分发安装。

## 🛠 技术栈

- **C++17 & Qt 5.15**
- **Qt 模块**：Core, Gui, Quick, Network, WebSockets, SerialPort (可选)
- **构建系统**：CMake

## 🚀 编译与运行

### 环境依赖
以 Debian/Ubuntu 系统为例，需要安装以下依赖：
```bash
sudo apt update
sudo apt install build-essential cmake qt5-qmake qtbase5-dev qtdeclarative5-dev libqt5websockets5-dev libqt5serialport5-dev
sudo apt install qml-module-qtquick2 qml-module-qtquick-controls2 qml-module-qt-labs-settings qml-module-qtquick-layouts
```

### 构建步骤
```bash
mkdir build && cd build
cmake ..
make -j$(nproc)
```

### 运行
构建完成后即可直接启动：
```bash
./NexusQt
```
如需在嵌入式设备上全屏运行：
```bash
./NexusQt --fullscreen
```

### 打包 (DEB) 与交叉编译
本项目提供了便捷的打包与跨平台编译支持：

**本地打包：**
```bash
cd build
cpack -G DEB
```

**Docker 交叉编译 (ARM64)：**
如果需要在 x86 主机上为 ARM64 架构（如 RK3528）直接编译并打包，可以使用项目中提供的 Docker 交叉编译脚本：
```bash
./scripts/cross_build_docker.sh
```
该脚本将会在干净的 Docker 环境中完成编译打包，最终的 `.deb` 产物会生成在 `build/packages/` 目录下。直接将其传输到目标设备的 Debian/Ubuntu 环境中，通过 `sudo apt install ./<package>.deb` 即可一键安装并自动配置好环境。

## 📂 项目结构
- `src/`：C++ 核心代码，包含系统监控、天气获取、唤醒逻辑的模型。
- `qml/`：QML 界面代码，包含主窗口布局、页面 (pages) 和组件 (components)。
- `packaging/`：Linux 桌面快捷方式、图标及 Debian 安装脚本。
- `resources.qrc`：Qt 资源文件。

## 🤝 贡献与反馈
本项目为 [Nexus](https://github.com/SuoNam/Nexus) 的一部分。欢迎提交 Issue 与 Pull Request。

## 📄 许可证
请参考主仓库的 License 设置。
