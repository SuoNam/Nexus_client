import QtQuick 2.15

Item {
    property var todayWeather:    null
    property var tomorrowWeather: null

    // ── 今天（左侧固定） ──────────────────────────────────────
    WeatherCard {
        anchors {
            left:             parent.left
            leftMargin:       parent.width * 0.03
            verticalCenter:   parent.verticalCenter
        }
        width:  parent.width * 0.20
        // 高度不超过宽度的 1.4 倍，避免大屏上卡片过高
        height: Math.min(parent.height * 0.80, width * 1.4)
        weather: todayWeather
        isToday: true
    }

    // ── 时钟（绝对居中，字体同时受宽高约束） ─────────────────
    Text {
        id: clockText
        anchors.centerIn: parent
        text: calendarModel.time
        // height*0.28 在 720p 约 130px，1080p 约 200px；
        // width*0.115 防止字宽超过中间剩余区域（1 - 2*0.23 = 0.54W）
        font.pixelSize: Math.min(parent.height * 0.28, parent.width * 0.10)
        font.bold:      true
        color:          Qt.rgba(1, 1, 1, 0.96)
        font.family:    "Monospace"
        font.letterSpacing: parent.width * 0.003
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: clockText.top
        anchors.bottomMargin: Math.max(10, parent.height * 0.025)
        width: parent.width * 0.52
        text: calendarModel.date
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Math.max(16, Math.min(parent.width * 0.022, parent.height * 0.055))
        color: "#c7d5e6"
        fontSizeMode: Text.Fit
        minimumPixelSize: 12
    }
    Text {
        id: dayStatus
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: clockText.bottom
        anchors.topMargin: Math.max(10, parent.height * 0.025)
        width: parent.width * 0.50
        text: calendarModel.status
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        font.pixelSize: Math.max(14, Math.min(parent.width * 0.020, parent.height * 0.048))
        color: calendarModel.holiday ? "#ffcf7a" : "#c7d5e6"
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: dayStatus.bottom
        anchors.topMargin: 8
        width: parent.width * 0.50
        text: calendarModel.location
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        font.pixelSize: Math.max(11, Math.min(parent.width * 0.013, 18))
        color: "#97aabd"
    }

    // ── 明天（右侧固定） ──────────────────────────────────────
    WeatherCard {
        anchors {
            right:           parent.right
            rightMargin:     parent.width * 0.03
            verticalCenter:  parent.verticalCenter
        }
        width:  parent.width * 0.20
        height: Math.min(parent.height * 0.80, width * 1.4)
        weather: tomorrowWeather
        isToday: false
    }
}
