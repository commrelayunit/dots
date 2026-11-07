// SPDX-License-Identifier: GPL-3.0-or-later
// icon (click = mute) · slider · value · optional device expander
import QtQuick
import ".."

Rectangle {
    id: root
    property string icon: ""
    property string title: ""
    property real value: 0
    property bool muted: false
    property bool expandable: false
    property bool expanded: false
    property color tint: Theme.accent
    default property alias content: inner.data
    signal moved(real v)
    signal iconClicked()

    implicitWidth: 360
    implicitHeight: 62 + (expanded ? inner.childrenRect.height + 8 : 0)
    radius: Theme.radiusCard
    color: Theme.card
    clip: true
    Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    Label {
        x: 14; y: 8
        width: parent.width - 60
        text: root.title
        color: Theme.subtext
        size: Theme.fontSmall - 0.5
    }
    Glyph {
        visible: root.expandable
        anchors.right: parent.right
        anchors.rightMargin: 12
        y: 6
        text: Icons.chevronR
        rotation: root.expanded ? 90 : 0
        color: Theme.subtext
        Behavior on rotation { NumberAnimation { duration: 160 } }
        MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: root.expanded = !root.expanded }
    }
    Row {
        x: 6; y: 26
        spacing: 8
        IconButton { icon: root.icon; size: 30; active: !root.muted; tint: root.tint; onClicked: root.iconClicked() }
        Bar {
            width: root.width - 100
            anchors.verticalCenter: parent.verticalCenter
            value: root.muted ? 0 : root.value
            interactive: true
            fill: root.muted ? Theme.muted : root.tint
            onMoved: v => root.moved(v)
        }
        Label { text: root.muted ? "off" : Math.round(root.value * 100) + "%"; width: 40; size: Theme.fontSmall; color: Theme.subtext; anchors.verticalCenter: parent.verticalCenter }
    }
    Column {
        id: inner
        y: 66
        x: 10
        width: parent.width - 20
        spacing: 2
        visible: root.expanded
    }
}
