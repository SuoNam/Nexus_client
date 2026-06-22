import QtQuick
import QtQuick.Controls

// 全屏遮罩 + 对话框
Item {
    id: root
    parent: Overlay.overlay
    anchors.fill: parent
    visible: false
    z: 9999

    signal accepted(string label, string target, string suffix)

    function open()  {
        labelInput.text  = ""
        targetInput.text = ""
        suffixInput.text = ""
        visible = true
    }
    function close() { visible = false }

    // 顶层 inline 组件（Qt5.15 支持，不能嵌套）
    component DlgField: Column {
        property string fieldLabel: ""
        property alias  text:        tf.text
        property string placeholder: ""
        spacing: 5

        Text {
            text: fieldLabel
            font.pixelSize: 11
            color: Qt.rgba(1, 0.75, 0.47, 0.65)
        }
        Rectangle {
            width: parent.width; height: 34; radius: 7
            color: Qt.rgba(0, 0, 0, 0.4)
            border.color: tf.activeFocus
                          ? Qt.rgba(1, 0.55, 0.24, 0.75)
                          : Qt.rgba(1, 0.55, 0.24, 0.35)
            TextInput {
                id: tf
                anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                verticalAlignment: TextInput.AlignVCenter
                color: "#ffd8a0"
                font.pixelSize: 13
                clip: true
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: parent.displayText.length === 0 ? parent.parent.parent.placeholder : ""
                    color: Qt.rgba(1, 0.75, 0.47, 0.3)
                    font.pixelSize: 13
                }
            }
        }
    }

    component DlgButton: Rectangle {
        id: db
        property string label:  ""
        property bool   accent: false
        signal clicked()
        width: 90; height: 34; radius: 8
        color: ma.containsMouse
               ? (accent ? Qt.rgba(1, 0.4, 0, 0.35)   : Qt.rgba(1, 1, 1, 0.10))
               : (accent ? Qt.rgba(1, 0.4, 0, 0.22)   : Qt.rgba(1, 1, 1, 0.06))
        border.color: accent ? Qt.rgba(1, 0.55, 0.24, 0.55)
                             : Qt.rgba(1, 1, 1, 0.15)
        Text {
            anchors.centerIn: parent
            text:  db.label
            font.pixelSize: 13
            color: accent ? "#ffbe78" : Qt.rgba(1, 1, 1, 0.6)
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: db.clicked()
        }
    }

    // ── 背景遮罩 ───────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        MouseArea { anchors.fill: parent; onClicked: root.close() }
    }

    // ── 对话框主体 ─────────────────────────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width:  Math.min(parent.width * 0.42, 420)
        height: dlgCol.height + 48
        radius: 14
        color:  "#10141e"
        border.color: Qt.rgba(1, 0.55, 0.24, 0.45)
        border.width: 1

        Column {
            id: dlgCol
            anchors.top:   parent.top
            anchors.left:  parent.left
            anchors.right: parent.right
            anchors.margins: 24
            anchors.topMargin: 24
            spacing: 14

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "添加倒计时"
                font.pixelSize: 16; font.bold: true
                color: "#ffbe78"; font.letterSpacing: 1
            }

            DlgField {
                id: labelInput
                width: parent.width
                fieldLabel:  "事件名称"
                placeholder: "例：期末考试"
            }
            DlgField {
                id: targetInput
                width: parent.width
                fieldLabel:  "目标时间"
                placeholder: "2026-12-19T08:30:00"
            }
            DlgField {
                id: suffixInput
                width: parent.width
                fieldLabel:  "到时提示"
                placeholder: "已到时！"
            }

            Row {
                anchors.right: parent.right
                spacing: 10
                DlgButton {
                    label: "取消"; accent: false
                    onClicked: root.close()
                }
                DlgButton {
                    label: "确认添加"; accent: true
                    onClicked: {
                        if (!labelInput.text || !targetInput.text) return
                        root.accepted(
                            labelInput.text,
                            targetInput.text,
                            suffixInput.text || "已到时！"
                        )
                        root.close()
                    }
                }
            }
        }
    }
}
