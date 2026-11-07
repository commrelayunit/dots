// SPDX-License-Identifier: GPL-3.0-or-later
// A notification pops the island open with its card; hover holds it.
import QtQuick
import ".."
import "../services"
import "../components"

View {
    property real minWidth: 0
    implicitWidth: Math.max(440, minWidth)
    implicitHeight: Notifs.popup ? card.implicitHeight + 16 : Theme.islandHeight
    NotificationCard {
        id: card
        visible: Notifs.popup !== null
        notif: Notifs.popup
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(560, parent.implicitWidth - 16)
    }
}
