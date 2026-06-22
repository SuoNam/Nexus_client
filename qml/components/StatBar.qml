import QtQuick

Item {
    id: root
    // height 由父级 Column 决定（不再固定）

    property string label: ""
    property string subLabel: ""
    property string valueText: "0"
    property real   value: 0        // 0–100 percent
    property color  barColor: "#00ffa0"

    // 用 Item+anchors 代替 Row，避免 Row 内不能用 anchors.right 的限制
    Item {
        id: header
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
        anchors.topMargin: 2
        height: 24

        Row {
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                text: root.label
                font.pixelSize: 13
                font.bold: true
                color: Qt.rgba(0.78, 0.9, 1, 0.85)
                font.letterSpacing: 0.5
            }

            Text {
                text: root.subLabel
                font.pixelSize: 10
                color: Qt.rgba(0.78, 0.9, 1, 0.45)
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.valueText
            font.pixelSize: 16
            font.bold: true
            color: root.barColor
            font.family: "Monospace"
        }
    }

    // 进度条轨道
    Rectangle {
        id: track
        anchors.top:        header.bottom
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.topMargin:  4
        height: 10
        radius: 5
        color:        Qt.rgba(1, 1, 1, 0.06)
        border.color: Qt.rgba(1, 1, 1, 0.07)
        border.width: 1
        clip: true

        Rectangle {
            width: Math.max(3, track.width * root.value / 100)
            height: parent.height
            radius: parent.radius
            color:  root.barColor
            Behavior on width {
                NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
            }
        }
    }
}
