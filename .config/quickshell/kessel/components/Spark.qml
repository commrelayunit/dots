// SPDX-License-Identifier: GPL-3.0-or-later
// Tiny bar sparkline (values normalised to the max, or 0..1 if `max` is set).
import QtQuick
import ".."

Row {
    id: root
    property var values: []
    property real max: 0               // 0 = auto
    property color tint: Theme.accent
    property real barWidth: 2
    property int count: 24
    height: 16
    spacing: 1
    readonly property var shown: values.slice(-count)
    readonly property real peak: max > 0 ? max : Math.max(1e-6, ...shown, 1e-6)
    Repeater {
        model: root.count
        Rectangle {
            required property int index
            readonly property int vi: index - (root.count - root.shown.length)
            readonly property real v: vi >= 0 ? Math.min(1, root.shown[vi] / root.peak) : 0
            width: root.barWidth
            height: Math.max(1.5, v * root.height)
            radius: 1
            anchors.bottom: parent.bottom
            color: vi >= 0 ? root.tint : Theme.a(Theme.text, 0.12)
            opacity: vi >= 0 ? 0.35 + 0.65 * v : 1
            Behavior on height { NumberAnimation { duration: 300 } }
        }
    }
}
