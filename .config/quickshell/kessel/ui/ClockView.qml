// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import ".."
import "../services"

Row {
    property bool expanded: false
    spacing: 10

    Text {
        text: "󰥔"
        color: Theme.accent
        font.family: Theme.font
        font.pointSize: Theme.fontUi
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: Time.time
        color: Theme.text
        font.family: Theme.font
        font.pointSize: Theme.fontUi
        font.bold: true
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: expanded ? Time.dateLong : Time.dateShort
        color: Theme.subtext
        font.family: Theme.font
        font.pointSize: Theme.fontUi
        anchors.verticalCenter: parent.verticalCenter
    }
}
