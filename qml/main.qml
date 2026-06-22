import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "pages"
import "components"

Window {
    id: root
    title: "Nexus"
    color: "#05070b"

    // 开发：窗口模式；嵌入式运行时通过 NEXUS_FULLSCREEN=1 全屏
    width:  1280
    height: 720

    Component.onCompleted: {
        if (Qt.application.arguments.indexOf("--fullscreen") >= 0)
            visibility = Window.FullScreen
        else
            show()
    }

    property int currentPage: 0
    readonly property int pageCount: 3

    // ── 背景渐变 ──────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0a0d14" }
            GradientStop { position: 1.0; color: "#05070b" }
        }
    }

    // ── 扫描线叠加（轻量，不用 blur） ─────────────────────────
    Canvas {
        anchors.fill: parent
        opacity: 0.035
        renderStrategy: Canvas.Threaded
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = "rgba(255,255,255,0.9)"
            for (var y = 0; y < height; y += 6) {
                ctx.fillRect(0, y, width, 1)
            }
        }
    }

    // ── 页面轨道 ──────────────────────────────────────────────
    Item {
        id: track
        width:  root.width * root.pageCount
        height: root.height
        x: -root.currentPage * root.width

        Behavior on x {
            NumberAnimation { duration: 320; easing.type: Easing.InOutCubic }
        }

        Page1 { x: 0;              width: root.width; height: root.height }
        Page2 { x: root.width;     width: root.width; height: root.height }
        Page3 { x: root.width * 2; width: root.width; height: root.height }
    }

    // ── 右上角关闭按钮（触摸 / 鼠标均可用） ──────────────────
    Rectangle {
        anchors.top:        parent.top
        anchors.right:      parent.right
        anchors.topMargin:  10
        anchors.rightMargin: 10
        width: 36; height: 36; radius: 8
        color: closeArea.containsMouse ? Qt.rgba(1, 0.2, 0.2, 0.55)
                                       : Qt.rgba(1, 1, 1, 0.08)
        border.color: Qt.rgba(1, 1, 1, 0.15)
        border.width: 1
        z: 100

        Text {
            anchors.centerIn: parent
            text: "✕"
            font.pixelSize: 16
            color: closeArea.containsMouse ? "white" : Qt.rgba(1, 1, 1, 0.5)
        }

        MouseArea {
            id: closeArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Qt.quit()
        }

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    // ── 底部导航点 ────────────────────────────────────────────
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        spacing: 10

        Repeater {
            model: root.pageCount
            Rectangle {
                width:  index === root.currentPage ? 18 : 6
                height: 6
                radius: 3
                color:  index === root.currentPage
                        ? "#00ffcc" : Qt.rgba(1, 1, 1, 0.2)
                Behavior on width { NumberAnimation { duration: 200 } }
                Behavior on color { ColorAnimation  { duration: 200 } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.currentPage = index
                }
            }
        }
    }

    // ── 左右箭头按钮 ──────────────────────────────────────────
    NavButton {
        anchors.left:           parent.left
        anchors.leftMargin:     28
        anchors.bottom:         parent.bottom
        anchors.bottomMargin:   20
        label:   "‹"
        enabled: root.currentPage > 0
        onClicked: root.currentPage--
    }

    NavButton {
        anchors.right:          parent.right
        anchors.rightMargin:    28
        anchors.bottom:         parent.bottom
        anchors.bottomMargin:   20
        label:   "›"
        enabled: root.currentPage < root.pageCount - 1
        onClicked: root.currentPage++
    }

    // ── 键盘 / 触摸（必须放在 Item 上才支持 focus/Keys） ─────
    Item {
        anchors.fill: parent
        focus: true

        Keys.onLeftPressed:  if (root.currentPage > 0) root.currentPage--
        Keys.onRightPressed: if (root.currentPage < root.pageCount - 1) root.currentPage++
        Keys.onEscapePressed: Qt.quit()
        Keys.onPressed: if (e.key === Qt.Key_Q && (e.modifiers & Qt.ControlModifier)) Qt.quit()

        property real _swipeStartX: 0

        MultiPointTouchArea {
            anchors.fill: parent
            // 只处理真实触摸事件；鼠标点击穿透给按钮
            mouseEnabled: false
            onPressed:  parent._swipeStartX = touchPoints[0].x
            onReleased: {
                var dx = touchPoints[0].x - parent._swipeStartX
                if (Math.abs(dx) > 60) {
                    if (dx < 0 && root.currentPage < root.pageCount - 1) root.currentPage++
                    else if (dx > 0 && root.currentPage > 0)             root.currentPage--
                }
            }
        }
    }

    // ── 内联导航按钮组件 ──────────────────────────────────────
    component NavButton: Rectangle {
        id: nb
        property string label: ""
        property bool enabled: true
        signal clicked()

        width: 44; height: 44; radius: 10
        color: nb.enabled ? (nbArea.containsMouse ? "#1a2030" : "#101520") : "transparent"
        border.color: nb.enabled ? "#1a3040" : "transparent"
        opacity: nb.enabled ? 1.0 : 0.0

        Text {
            anchors.centerIn: parent
            text: nb.label
            font.pixelSize: 24
            color: "#60d0ff"
        }
        MouseArea {
            id: nbArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: nb.enabled
            onClicked: nb.clicked()
        }
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }
}
