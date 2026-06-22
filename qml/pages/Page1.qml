import QtQuick
import "../components"

Item {
    // ── 倒计时 banner ─────────────────────────────────────────
    CountdownBanner {
        id: banner
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.topMargin:  16
        anchors.leftMargin: 20
        anchors.rightMargin: 20
    }

    // ── 时钟 + 天气 ───────────────────────────────────────────
    ClockWeatherRow {
        anchors.top:    banner.bottom
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.topMargin:    10
        anchors.bottomMargin: 44

        todayWeather:    weatherModel.today
        tomorrowWeather: weatherModel.tomorrow
    }
}
