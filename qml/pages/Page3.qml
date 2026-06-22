import QtQuick 2.15

Item {
    // ── 顶部 banner ───────────────────────────────────────────
    Rectangle {
        id: banner
        anchors.top:         parent.top
        anchors.left:        parent.left
        anchors.right:       parent.right
        anchors.topMargin:   16
        anchors.leftMargin:  20
        anchors.rightMargin: 20
        height: 56
        radius: 12
        color: "transparent"
        border.color: Qt.rgba(0, 0.8, 1, 0.4)
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "设备管理"
            font.pixelSize: 22
            font.bold: true
            color: "#78d8ff"
            font.letterSpacing: 4
        }
    }

    // ── 主体占位区域 ──────────────────────────────────────────
    Rectangle {
        anchors.top:         banner.bottom
        anchors.left:        parent.left
        anchors.right:       parent.right
        anchors.bottom:      parent.bottom
        anchors.topMargin:   14
        anchors.leftMargin:  20
        anchors.rightMargin: 20
        anchors.bottomMargin: 50
        radius: 14
        color: "transparent"
        border.color: Qt.rgba(1, 1, 1, 0.07)
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 16
            opacity: 0.3

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "⬡"
                font.pixelSize: 64
                color: "#00ccff"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "NEXUS · 设备管理"
                font.pixelSize: 18
                font.bold: true
                color: "#c8e6ff"
                font.letterSpacing: 3
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "功能开发中"
                font.pixelSize: 13
                color: "#8090b0"
                font.letterSpacing: 1
            }
        }
    }
}
