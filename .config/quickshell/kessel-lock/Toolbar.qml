// SPDX-License-Identifier: GPL-3.0-or-later
// Rounded pill that holds toolbar items in a row.
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    default property alias items: row.data
    implicitHeight: 52
    implicitWidth: row.implicitWidth + 16
    radius: height / 2
    color: Style.toolbar
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.08)
    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 4
    }
}
