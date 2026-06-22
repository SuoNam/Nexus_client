import QtQuick

Rectangle {
    id: root
    radius: 16
    color:  "transparent"
    border.color: Qt.rgba(0, 0.78, 1, 0.2)
    border.width: 1
    clip: true

    function cpuColor(v)  { return v < 50  ? "#00ffa0" : v < 80  ? "#ffcc00" : "#ff4444" }
    function memColor(v)  { return v < 60  ? "#00ffa0" : v < 85  ? "#ffcc00" : "#ff4444" }
    function loadColor(v) { return v < 1.0 ? "#00ffa0" : v < 2.5 ? "#ffcc00" : "#ff4444" }

    // barH 只依赖 root.height，不在 Column 内定义，彻底断开循环
    readonly property real barH: Math.min(Math.max((root.height - 30) / 4, 38), 58)

    Column {
        anchors {
            left: parent.left;   leftMargin:  24
            right: parent.right; rightMargin: 24
            verticalCenter: parent.verticalCenter
        }
        spacing: 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "本机系统状态"
            font.pixelSize: 14; font.bold: true
            font.letterSpacing: 3
            color: Qt.rgba(0, 0.86, 1, 0.75)
        }

        StatBar {
            width: parent.width; height: root.barH
            label:     "CPU 使用率"
            valueText: sysMonitor.cpuUsage.toFixed(1) + " %"
            value:     sysMonitor.cpuUsage
            barColor:  root.cpuColor(sysMonitor.cpuUsage)
        }

        StatBar {
            width: parent.width; height: root.barH
            label:     "内存使用率"
            valueText: sysMonitor.memUsage.toFixed(1) + " %"
            value:     sysMonitor.memUsage
            barColor:  root.memColor(sysMonitor.memUsage)
        }

        StatBar {
            width: parent.width; height: root.barH
            label:    "系统负载"
            subLabel: "(1 min)"
            valueText: sysMonitor.loadAvg.toFixed(2)
            value:     Math.min(100, sysMonitor.loadAvg / 4 * 100)
            barColor:  root.loadColor(sysMonitor.loadAvg)
        }

        Rectangle {
            width:   parent.width
            height:  !sysMonitor.connected ? 28 : 0
            visible: !sysMonitor.connected
            color:        "transparent"
            border.color: Qt.rgba(1, 0.55, 0.16, 0.25)
            border.width: 1
            radius: 6
            clip: true
            Behavior on height { NumberAnimation { duration: 200 } }
            Text {
                anchors.centerIn: parent
                text: "⚠  无法读取本地 /proc，请检查权限"
                font.pixelSize: 10
                color: Qt.rgba(1, 0.7, 0.24, 0.6)
            }
        }
    }
}
