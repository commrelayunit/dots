// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import ".."

Rectangle {
    id: root
    property string icon: ""
    property real size: 32
    property real iconSize: Theme.fontUi + 3
    property bool active: false
    property color tint: Theme.accent
    signal clicked()

    implicitWidth: size
    implicitHeight: size
    radius: size / 2
    color: active ? Theme.a(tint, 0.22) : (ma.containsMouse ? Theme.cardHi : "transparent")
    Behavior on color { ColorAnimation { duration: Theme.fadeMs } }

    Glyph {
        anchors.centerIn: parent
        text: root.icon
        size: root.iconSize
        optical: true
        color: root.active ? root.tint : Theme.text
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
