// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import ".."

Rectangle {
    id: root
    property bool checked: false
    signal toggled()
    implicitWidth: 36
    implicitHeight: 20
    radius: 10
    color: checked ? Theme.accent : Theme.overlay
    Behavior on color { ColorAnimation { duration: Theme.fadeMs } }
    Rectangle {
        width: 14; height: 14; radius: 7
        y: 3
        x: root.checked ? root.width - width - 3 : 3
        color: root.checked ? Theme.base : Theme.subtext
        Behavior on x { NumberAnimation { duration: Theme.fadeMs; easing.type: Easing.OutCubic } }
    }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.toggled() }
}
