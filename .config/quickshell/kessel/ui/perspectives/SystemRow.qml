// SPDX-License-Identifier: GPL-3.0-or-later
// System perspective: CPU / RAM sparklines, live ↓/↑ graphs, uptime.
import QtQuick
import "../.."
import "../../services"
import "../../components"

Item {
    implicitWidth: row.implicitWidth
    implicitHeight: Theme.islandHeight
    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16
        Row { spacing: 6; anchors.verticalCenter: parent.verticalCenter
            Chip { icon: Icons.cpu; text: Stats.pct(Stats.cpu); anchors.verticalCenter: parent.verticalCenter }
            Spark { values: Stats.cpuHist; max: 1; tint: Stats.cpu > 0.85 ? Theme.red : Theme.accent; anchors.verticalCenter: parent.verticalCenter } }
        Row { spacing: 6; anchors.verticalCenter: parent.verticalCenter
            Chip { icon: Icons.memory; text: Stats.pct(Stats.mem); anchors.verticalCenter: parent.verticalCenter }
            Spark { values: Stats.memHist; max: 1; tint: Theme.purple; anchors.verticalCenter: parent.verticalCenter } }
        Row { spacing: 6; anchors.verticalCenter: parent.verticalCenter
            Chip { icon: Icons.download; text: Stats.compact(Stats.rxRate); anchors.verticalCenter: parent.verticalCenter }
            Spark { values: Stats.rxHist; tint: Theme.green; anchors.verticalCenter: parent.verticalCenter } }
        Row { spacing: 6; anchors.verticalCenter: parent.verticalCenter
            Chip { icon: Icons.upload; text: Stats.compact(Stats.txRate); anchors.verticalCenter: parent.verticalCenter }
            Spark { values: Stats.txHist; tint: Theme.yellow; anchors.verticalCenter: parent.verticalCenter } }
        Chip { icon: Icons.timer; text: "up " + User.uptime; anchors.verticalCenter: parent.verticalCenter }
    }
}
