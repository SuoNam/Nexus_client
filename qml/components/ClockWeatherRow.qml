import QtQuick 2.15

Item {
    property var todayWeather:    null
    property var tomorrowWeather: null

    property string _time: "00:00:00"

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            var d = new Date()
            parent._time = String(d.getHours()).padStart(2,"0") + ":" +
                           String(d.getMinutes()).padStart(2,"0") + ":" +
                           String(d.getSeconds()).padStart(2,"0")
        }
    }

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
        anchors.centerIn: parent
        text: _time
        // height*0.28 在 720p 约 130px，1080p 约 200px；
        // width*0.115 防止字宽超过中间剩余区域（1 - 2*0.23 = 0.54W）
        font.pixelSize: Math.min(parent.height * 0.28, parent.width * 0.115)
        font.bold:      true
        color:          Qt.rgba(1, 1, 1, 0.96)
        font.family:    "Monospace"
        font.letterSpacing: parent.width * 0.003
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
