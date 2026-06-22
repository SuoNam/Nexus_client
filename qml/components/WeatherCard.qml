import QtQuick 2.15

Rectangle {
    id: root

    property var  weather: null
    property bool isToday: true

    readonly property color _accent: isToday ? "#ffa030" : "#50b4ff"
    readonly property color _dim:    isToday ? Qt.rgba(1,0.6,0.18,0.35) : Qt.rgba(0.3,0.7,1,0.3)

    // 所有字体以卡片宽度为基准，宽度由父级控制（窗口 20%），不随高度失控膨胀
    readonly property real _w: root.width

    radius: 14
    color:  "transparent"
    border.color: _dim
    border.width: 1.5

    Column {
        anchors.centerIn: parent
        spacing: _w * 0.06

        // 今天 / 明天
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  (root.weather && root.weather["label"]) ? root.weather["label"]
                                                           : (root.isToday ? "今天" : "明天")
            font.pixelSize: Math.max(12, _w * 0.10)
            font.bold: true
            color: root._accent
            font.letterSpacing: 1
        }

        // 天气描述
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: (root.weather && root.weather["text"]) ? root.weather["text"] : "--"
            font.pixelSize: Math.max(11, _w * 0.09)
            font.bold: true
            color: Qt.rgba(0.87, 0.94, 1, 0.9)
        }

        // 最高 / 最低温度
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: _w * 0.02

            Text {
                text: root.weather ? (root.weather["tempMax"] || "--") + "°" : "--°"
                font.pixelSize: Math.max(24, _w * 0.22)
                font.bold: true
                color: root._accent
            }
            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: _w * 0.04
                text: "/"
                font.pixelSize: Math.max(14, _w * 0.13)
                font.weight: Font.Light
                color: Qt.rgba(1, 1, 1, 0.28)
            }
            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: _w * 0.02
                text: root.weather ? (root.weather["tempMin"] || "--") + "°" : "--°"
                font.pixelSize: Math.max(18, _w * 0.17)
                font.bold: true
                color: Qt.lighter(root._accent, 1.4)
                opacity: 0.85
            }
        }

        // 风向风力
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: (root.weather && root.weather["windDir"])
                  ? root.weather["windDir"] + " " + (root.weather["windScale"] || "") + "级"
                  : "加载中..."
            font.pixelSize: Math.max(10, _w * 0.075)
            color: Qt.rgba(0.78, 0.87, 1, 0.6)
        }
    }
}
