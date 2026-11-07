// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import ".."
import "../services"
import "../components"

View {
    implicitWidth: 300
    implicitHeight: Theme.islandHeight + 4
    Row {
        anchors.centerIn: parent
        spacing: 12
        Glyph { text: IslandState.osdIcon; size: Theme.fontUi + 4; anchors.verticalCenter: parent.verticalCenter }
        Bar { width: 170; value: IslandState.osdValue; anchors.verticalCenter: parent.verticalCenter }
        Label { text: IslandState.osdLabel; width: 64; size: Theme.fontSmall; color: Theme.subtext; anchors.verticalCenter: parent.verticalCenter }
    }
}
