// SPDX-License-Identifier: GPL-3.0-or-later
// Small "now playing" equaliser; still when paused.
import QtQuick
import ".."

Row {
    property bool playing: false
    property color tint: Theme.accent2
    spacing: 2
    height: 12
    Repeater {
        model: 4
        Rectangle {
            required property int index
            width: 3
            radius: 1.5
            color: parent.tint
            anchors.bottom: parent.bottom
            height: 4
            SequentialAnimation on height {
                running: parent.playing
                loops: Animation.Infinite
                alwaysRunToEnd: true
                NumberAnimation { to: 12 - index * 2; duration: 260 + index * 70; easing.type: Easing.InOutSine }
                NumberAnimation { to: 3 + index; duration: 300 + index * 50; easing.type: Easing.InOutSine }
            }
        }
    }
}
