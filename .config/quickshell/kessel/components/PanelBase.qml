// SPDX-License-Identifier: GPL-3.0-or-later
// Base for expanded panels: padding, a title row, Esc to close.
import QtQuick
import ".."
import "../services"

FocusScope {
    id: root
    property string title: ""
    property string icon: ""
    default property alias content: body.data
    property alias headerExtra: extra.data
    property int contentWidth: 520
    property int contentHeight: body.childrenRect.height

    implicitWidth: contentWidth + 2 * Theme.pad + 8
    implicitHeight: header.height + contentHeight + 3 * Theme.pad

    Keys.onEscapePressed: IslandState.closePanel()

    Row {
        id: header
        x: Theme.pad + 4
        y: Theme.pad
        height: 26
        spacing: 8
        Glyph { text: root.icon; color: Theme.accent; anchors.verticalCenter: parent.verticalCenter }
        Label { text: root.title; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
    }
    Row {
        id: extra
        anchors.right: parent.right
        anchors.rightMargin: Theme.pad + 4
        y: Theme.pad
        height: 26
        spacing: 4
    }
    Item {
        id: body
        x: Theme.pad + 4
        anchors.top: header.bottom
        anchors.topMargin: Theme.pad
        width: root.contentWidth
        height: root.contentHeight
    }
}
