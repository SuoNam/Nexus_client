import QtQuick 2.15

Rectangle {
    id: root
    radius: 12
    color: "transparent"
    border.color: Qt.rgba(1, 1, 1, 0.08)
    border.width: 1
    clip: true

    // ── 格式化速率 ─────────────────────────────────────────────
    function fmt(mbps) {
        if (mbps < 1) return (mbps * 1024).toFixed(0) + " KB/s"
        return mbps.toFixed(2) + " MB/s"
    }

    readonly property string wiredText:
        "↓ " + fmt(sysMonitor.wiredDown) + "   ↑ " + fmt(sysMonitor.wiredUp)
    readonly property string hotspotText:
        "↓ " + fmt(sysMonitor.hotspotDown) + "   ↑ " + fmt(sysMonitor.hotspotUp)

    // ── 上半图：有线网卡 ──────────────────────────────────────
    Item {
        id: topChart
        anchors.top:    parent.top
        anchors.left:   parent.left
        anchors.right:  parent.right
        height: parent.height / 2

        Text {
            x: 10; y: 6
            text: "笔记本有线"
            font.pixelSize: 11
            color: "#666666"
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 14
            y: 6
            spacing: 8
            Text { text: "■ 下行"; font.pixelSize: 10; color: "#00ffff" }
            Text { text: "■ 上行"; font.pixelSize: 10; color: "#ff8800" }
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 14
            y: 20
            text: root.wiredText
            font.pixelSize: 11
            color: "#00ffff"
            font.family: "Monospace"
        }

        ChartCanvas {
            anchors.fill: parent
            data1: sysMonitor.wiredDownHist
            data2: sysMonitor.wiredUpHist
            color1: "#00ffff"
            color2: "#ff8800"
        }
    }

    // 分隔线
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height / 2
        width: parent.width - 20
        height: 1
        color: Qt.rgba(1, 1, 1, 0.06)
    }

    // ── 下半图：手机热点 ──────────────────────────────────────
    Item {
        id: bottomChart
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height: parent.height / 2

        Text {
            x: 10; y: 6
            text: "手机热点"
            font.pixelSize: 11
            color: "#666666"
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 14
            y: 6
            text: root.hotspotText
            font.pixelSize: 11
            color: "#00ffff"
            font.family: "Monospace"
        }

        ChartCanvas {
            anchors.fill: parent
            data1: sysMonitor.hotspotDownHist
            data2: sysMonitor.hotspotUpHist
            color1: "#00ffff"
            color2: "#ff8800"
        }
    }

    // ── Canvas 折线图子组件 ────────────────────────────────────
    component ChartCanvas: Canvas {
        id: cv
        property var data1: []
        property var data2: []
        property color color1: "#00ffff"
        property color color2: "#ff8800"

        // 数据变化时重绘
        onData1Changed: requestPaint()
        onData2Changed: requestPaint()

        renderStrategy: Canvas.Cooperative   // 嵌入式平台友好

        onPaint: {
            var ctx = getContext("2d")
            var w = width, h = height
            ctx.clearRect(0, 0, w, h)

            var d1 = data1, d2 = data2
            if (!d1 || d1.length < 2) return

            // 自动缩放
            var maxVal = 1.0
            for (var i = 0; i < d1.length; i++) if (d1[i] > maxVal) maxVal = d1[i]
            for (var i = 0; i < d2.length; i++) if (d2[i] > maxVal) maxVal = d2[i]
            maxVal = Math.max(10, maxVal * 1.25)

            var padTop = 28, padBot = 4
            var chartH = h - padTop - padBot
            var n = d1.length

            // 网格线（3 条）
            ctx.strokeStyle = "rgba(255,255,255,0.04)"
            ctx.lineWidth = 1
            for (var g = 1; g <= 3; g++) {
                var gy = padTop + (1 - g / 4) * chartH
                ctx.beginPath(); ctx.moveTo(0, gy); ctx.lineTo(w, gy); ctx.stroke()
            }

            // 绘制一条折线 + 填充区域
            function drawLine(data, color, doFill) {
                if (!data || data.length < 2) return
                ctx.beginPath()
                ctx.lineWidth = 1.5
                ctx.strokeStyle = color
                for (var i = 0; i < data.length; i++) {
                    var x = (i / (n - 1)) * w
                    var y = padTop + (1 - data[i] / maxVal) * chartH
                    if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                }
                ctx.stroke()

                if (doFill) {
                    ctx.lineTo(w, padTop + chartH)
                    ctx.lineTo(0, padTop + chartH)
                    ctx.closePath()
                    // Qt QML Canvas color 可直接转为 rgba 字符串
                    ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.09)
                    ctx.fill()
                }
            }

            drawLine(d1, color1, true)
            drawLine(d2, color2, false)
        }
    }
}
