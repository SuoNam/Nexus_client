import QtQuick 2.15
import Qt.labs.settings 1.1

Rectangle {
    id: root
    height: column.implicitHeight + 20
    radius: 12
    color:  "transparent"
    border.color: Qt.rgba(1, 0.55, 0.24, 0.5)
    border.width: 1

    // ── 持久化 ─────────────────────────────────────────────────
    Settings {
        id: store
        category: "Countdowns"
    }

    // Defaults apply only when the key is absent; an explicitly saved [] stays empty.
    property var defaultItems: [
            { id:"kaoyan", label:"距离 2027 考研初试还有",
              target:"2026-12-19T08:30:00", suffix:"考试已开始！" },
            { id:"cet6", label:"距离 英语六级 (6/13) 还有",
              target:"2026-06-13T09:00:00", suffix:"六级已开始" }
        ]

    property var cdItems: []
    property var texts:   []

    Component.onCompleted: {
        var saved = store.value("items", null)
        try {
            var loaded = saved === null ? defaultItems : JSON.parse(saved)
            if (!Array.isArray(loaded)) throw new Error("Invalid countdown list")
            cdItems = loaded
        } catch (error) {
            console.warn("无法读取倒计时设置：", error)
            cdItems = []
        }
        recalc()
    }

    function saveItems(items) {
        // Explicit write + sync avoids Settings' deferred property-save timer.
        // Persist before changing the model, which may destroy the clicked delegate.
        store.setValue("items", JSON.stringify(items))
        store.sync()
        cdItems = items
        recalc()
    }

    function recalc() {
        var now = new Date()
        var arr = []
        for (var i = 0; i < cdItems.length; i++) {
            var diff = new Date(cdItems[i].target) - now
            if (diff <= 0) { arr.push(cdItems[i].suffix); continue }
            var d = Math.floor(diff / 86400000)
            var h = Math.floor((diff / 3600000)  % 24)
            var m = Math.floor((diff / 60000)    % 60)
            var s = Math.floor((diff / 1000)     % 60)
            arr.push(d + " 天 " + h + " 时 " + m + " 分 " + s + " 秒")
        }
        texts = arr
    }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: root.recalc()
    }

    // ── 内容列 ─────────────────────────────────────────────────
    Column {
        id: column
        anchors.top:          parent.top
        anchors.left:         parent.left
        anchors.right:        parent.right
        anchors.topMargin:    10
        anchors.leftMargin:   14
        anchors.rightMargin:  14
        spacing: 6

        Repeater {
            model: root.cdItems.length

            Row {
                width: column.width
                spacing: 6

                Text {
                    width: parent.width - delBtn.width - parent.spacing
                    text:  root.cdItems[index].label + "：" +
                           (root.texts[index] !== undefined ? root.texts[index] : "")
                    font.pixelSize: Math.max(11, Math.min(parent.width * 0.022, 15))
                    color: "#ffbe78"
                    elide: Text.ElideRight
                }

                Rectangle {
                    id: delBtn
                    width: 20; height: 20; radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color:        delMa.containsMouse
                                  ? Qt.rgba(1, 0.3, 0.2, 0.3) : "transparent"
                    border.color: Qt.rgba(1, 0.4, 0.3, 0.5)
                    Text {
                        anchors.centerIn: parent
                        text: "✕"; font.pixelSize: 9; color: "#ff7060"
                    }
                    MouseArea {
                        id: delMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            var arr = root.cdItems.slice()
                            arr.splice(index, 1)
                            root.saveItems(arr)
                        }
                    }
                }
            }
        }

        // 添加按钮行
        Item {
            width: column.width; height: 24

            Rectangle {
                anchors.centerIn: parent
                width: 120; height: 22; radius: 5
                color: addMa.containsMouse
                       ? Qt.rgba(1, 0.55, 0.24, 0.15) : "transparent"
                border.color: Qt.rgba(1, 0.55, 0.24, 0.45)
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "+ 添加倒计时"; font.pixelSize: 11; color: "#ffbe78"
                }
                MouseArea {
                    id: addMa; anchors.fill: parent; hoverEnabled: true
                    onClicked: dlg.open()
                }
            }
        }
    }

    // ── 添加对话框（独立文件，支持 Overlay） ──────────────────
    AddCountdownDialog {
        id: dlg
        onAccepted: function(label, target, suffix) {
            var arr = root.cdItems.slice()
            arr.push({ id: Date.now().toString(),
                       label: label, target: target, suffix: suffix })
            root.saveItems(arr)
        }
    }
}
