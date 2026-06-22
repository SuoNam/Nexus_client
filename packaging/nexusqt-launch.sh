#!/bin/bash
# Nexus Qt 启动脚本
# 自动寻找当前桌面用户的 XAUTHORITY，解决 root 权限下无 DISPLAY 的问题

# 找桌面用户的 Xauthority（支持 Armbian/Ubuntu 桌面环境）
find_xauth() {
    for user_home in /home/* /root; do
        local xauth="$user_home/.Xauthority"
        [ -f "$xauth" ] && echo "$xauth" && return
    done
}

# DISPLAY 默认 :0
: "${DISPLAY:=:0}"

# XAUTHORITY 自动检测
if [ -z "$XAUTHORITY" ]; then
    XAUTH=$(find_xauth)
    [ -n "$XAUTH" ] && export XAUTHORITY="$XAUTH"
fi

export DISPLAY

# 网卡名配置（按 RK3528 实际接口修改）
# export NEXUS_WIRED_IFACE=eth0
# export NEXUS_HOTSPOT_IFACE=wlan0

exec /usr/bin/NexusQt "$@"
