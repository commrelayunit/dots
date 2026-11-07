// SPDX-License-Identifier: GPL-3.0-or-later
// "Time's up" — shown while Alarm.ringing (the pill also turns red and shakes).
import QtQuick
import ".."
import "../services"
import "../components"

View {
    implicitWidth: row.implicitWidth + 36
    implicitHeight: 64
    Row {
        id: row
        anchors.centerIn: parent
        spacing: 14
        Glyph {
            text: Icons.sand
            color: Theme.red
            size: Theme.fontUi + 8
            anchors.verticalCenter: parent.verticalCenter
            SequentialAnimation on rotation {
                running: Alarm.ringing
                loops: Animation.Infinite
                NumberAnimation { to: 18; duration: 70 }
                NumberAnimation { to: -18; duration: 140 }
                NumberAnimation { to: 0; duration: 70 }
                PauseAnimation { duration: 900 }
            }
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            Label { text: "Time's up"; font.bold: true; color: Theme.red; size: Theme.fontUi + 1 }
            Label { text: Alarm.label; color: Theme.subtext; size: Theme.fontSmall }
        }
        Item { width: 8; height: 1 }
        Rectangle {
            width: snoozeLabel.implicitWidth + 24; height: 32; radius: 16
            anchors.verticalCenter: parent.verticalCenter
            color: sma.containsMouse ? Theme.cardHi : Theme.card
            Label { id: snoozeLabel; anchors.centerIn: parent; text: "Snooze 5 min"; size: Theme.fontSmall }
            MouseArea { id: sma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Alarm.snooze(5) }
        }
        Rectangle {
            width: dismissLabel.implicitWidth + 28; height: 32; radius: 16
            anchors.verticalCenter: parent.verticalCenter
            color: dma.containsMouse ? Qt.lighter(Theme.red, 1.1) : Theme.red
            Label { id: dismissLabel; anchors.centerIn: parent; text: "Dismiss"; font.bold: true; size: Theme.fontSmall; color: Theme.base }
            MouseArea { id: dma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Alarm.dismiss() }
        }
    }
}
