cmake_minimum_required(VERSION 3.16)
project(NexusQt VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# ── Qt5 依赖 ──────────────────────────────────────────────────
find_package(Qt5 5.15 REQUIRED COMPONENTS
    Core Gui Quick Network WebSockets
)
find_package(Qt5 OPTIONAL_COMPONENTS SerialPort QUIET)
if (Qt5SerialPort_FOUND)
    message(STATUS "Qt5::SerialPort found — 串口唤醒启用")
else()
    message(STATUS "Qt5::SerialPort NOT found — 串口唤醒使用 QProcess 兜底")
endif()

# ── 构建目标 ──────────────────────────────────────────────────
qt5_add_resources(APP_RESOURCES resources.qrc)

add_executable(NexusQt
    main.cpp
    src/SystemMonitor.cpp
    src/WeatherModel.cpp
    src/WakeClient.cpp
    ${APP_RESOURCES}
)

target_include_directories(NexusQt PRIVATE src)

target_link_libraries(NexusQt PRIVATE
    Qt5::Core Qt5::Gui Qt5::Quick Qt5::Network Qt5::WebSockets
    $<$<BOOL:${Qt5SerialPort_FOUND}>:Qt5::SerialPort>
)
if (Qt5SerialPort_FOUND)
    target_compile_definitions(NexusQt PRIVATE HAS_SERIAL_PORT)
endif()

# ── 安装规则 ──────────────────────────────────────────────────
include(GNUInstallDirs)

install(TARGETS NexusQt
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
install(FILES packaging/nexusqt.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
)
install(PROGRAMS packaging/nexusqt-launch.sh
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    RENAME nexusqt
)
install(FILES packaging/nexusqt.png
    DESTINATION ${CMAKE_INSTALL_DATADIR}/pixmaps
    OPTIONAL
)

# ── CPack / DEB 打包 ──────────────────────────────────────────
set(CPACK_GENERATOR "DEB")
set(CPACK_PACKAGE_NAME    "nexusqt")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_CONTACT "suo <jiankunsuo5@gmail.com>")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY
    "Nexus 系统监控大屏 (Qt5, RK3528)")
set(CPACK_PACKAGE_DESCRIPTION
    "本地采集 CPU/内存/网速，直调 QWeather API 显示天气，\n串口唤醒设备。适用于 RK3528 等 ARM64 嵌入式 Linux 盒子。")

# 自动获取当前系统架构（在 RK3528 上构建时为 arm64）
execute_process(
    COMMAND dpkg --print-architecture
    OUTPUT_VARIABLE DEB_ARCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)
if (DEB_ARCH STREQUAL "")
    set(DEB_ARCH "arm64")   # 交叉构建时的默认值
endif()
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${DEB_ARCH}")

# 运行时依赖（在 Ubuntu/Debian ARM64 上验证过的包名）
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "libqt5quick5 (>= 5.12), \
libqt5network5 (>= 5.12), \
libqt5websockets5 (>= 5.12), \
qml-module-qtquick2, \
qml-module-qtquick-controls2, \
qml-module-qt-labs-settings, \
qml-module-qtquick-layouts"
)

set(CPACK_DEBIAN_PACKAGE_SECTION    "utils")
set(CPACK_DEBIAN_PACKAGE_PRIORITY   "optional")

# 安装后脚本：更新桌面数据库
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
    "${CMAKE_CURRENT_SOURCE_DIR}/packaging/postinst"
)

set(CPACK_PACKAGE_INSTALL_PREFIX "/usr")
set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_BINARY_DIR}/packages")

include(CPack)
