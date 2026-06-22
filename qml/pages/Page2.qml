import QtQuick
import "../components"

Item {

    // ── 顶部 Banner ───────────────────────────────────────────
    Rectangle {
        id: banner
        anchors { top: parent.top; topMargin: 14; left: parent.left; right: parent.right
                  leftMargin: 20; rightMargin: 20 }
        height: 50
        radius: 12
        color: "transparent"
        border.color: Qt.rgba(1, 0.55, 0.24, 0.5)
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 14

            Text {
                text: "设备名录"
                font.pixelSize: 20; font.bold: true
                color: "#ffbe78"; font.letterSpacing: 4
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:  sysMonitor.connected ? "● 实时" : "○ 离线"
                font.pixelSize: 12
                color: sysMonitor.connected ? "#00ffa0" : "#666"
            }
        }
    }

    // ── 底部区域（先声明以便 statsCard 使用 .top 锚点） ──────
    Item {
        id: bottomRow
        anchors {
            bottom: parent.bottom; bottomMargin: 46  // 导航点高度
            left: parent.left;  right: parent.right
            leftMargin: 20;     rightMargin: 20
        }
        height: Math.min(Math.max(parent.height * 0.30, 160), 220)

        // 唤醒面板（左）
        Rectangle {
            id: wakePanel
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: Math.min(parent.width * 0.26, 180)
            radius: 12
            color: "transparent"
            border.color: "#ff6600"; border.width: 1

            Column {
                anchors { top: parent.top; topMargin: 14; horizontalCenter: parent.horizontalCenter }
                spacing: 12

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "唤醒"; font.pixelSize: 13; font.bold: true
                    color: "#ff6600"; font.letterSpacing: 2
                }

                Rectangle {
                    width: Math.min(wakePanel.width - 24, 148); height: 36; radius: 8
                    color: wakeMA.containsMouse ? "#2a1500" : "#1a0d00"
                    border.color: "#ff6600"; border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "联想 G5000"; font.pixelSize: 12; color: "#ff9944"
                    }
                    MouseArea {
                        id: wakeMA; anchors.fill: parent; hoverEnabled: true
                        onClicked: wakeClient.wake()
                    }
                }
            }

            // 唤醒结果提示
            Connections {
                target: wakeClient
                function onWakeResult(success, message) {
                    wakeMsg.text    = message
                    wakeMsg.color   = success ? "#00ffa0" : "#ff4444"
                    wakeMsg.visible = true
                    wakeMsgTimer.restart()
                }
            }
            Text {
                id: wakeMsg
                anchors { bottom: parent.bottom; bottomMargin: 10; horizontalCenter: parent.horizontalCenter }
                font.pixelSize: 10; visible: false; wrapMode: Text.WordWrap
                width: parent.width - 12
                horizontalAlignment: Text.AlignHCenter
            }
            Timer { id: wakeMsgTimer; interval: 2500; onTriggered: wakeMsg.visible = false }
        }

        // 网速折线图（右）
        NetworkChart {
            anchors { left: wakePanel.right; leftMargin: 12; right: parent.right
                      top: parent.top; bottom: parent.bottom }
        }
    }

    // ── 系统状态卡片（弹性填充 banner 和 bottomRow 之间） ─────
    SystemStatsCard {
        anchors {
            top: banner.bottom; topMargin: 12
            bottom: bottomRow.top; bottomMargin: 12
            left: parent.left;  right: parent.right
            leftMargin: 20;     rightMargin: 20
        }
    }
}
