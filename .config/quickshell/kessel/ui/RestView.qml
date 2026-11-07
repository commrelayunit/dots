// SPDX-License-Identifier: GPL-3.0-or-later
// Resting island: workspaces + music on the left, the time in the middle,
// weather / system / network / battery and live activities on the right.
import QtQuick
import Quickshell
import ".."
import "../services"
import "../components"

View {
    id: root
    implicitWidth: row.implicitWidth + 32
    implicitHeight: Theme.islandHeight

    // Click anywhere that isn't a control → quick settings.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: IslandState.openPanel("control")
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 14

        // ── left wing ───────────────────────────────────────────────
        Row {
            id: workspaces
            spacing: 5
            anchors.verticalCenter: parent.verticalCenter
            Repeater {
                model: Hypr.maxId
                Rectangle {
                    required property int index
                    readonly property int wsId: index + 1
                    readonly property bool focused: Hypr.focusedId === wsId
                    readonly property bool used: Hypr.occupied(wsId)
                    anchors.verticalCenter: parent.verticalCenter
                    width: focused ? 18 : 7
                    height: 7
                    radius: 3.5
                    color: focused ? Theme.accent : used ? Theme.subtext : Theme.overlay
                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 200 } }
                    MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: Hypr.focus(parent.wsId) }
                }
            }
        }

        Row {
            visible: Media.active
            spacing: 7
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                width: 20; height: 20; radius: 10
                color: Theme.overlay
                clip: true
                anchors.verticalCenter: parent.verticalCenter
                Image { anchors.fill: parent; source: Media.art; fillMode: Image.PreserveAspectCrop; asynchronous: true; visible: status === Image.Ready }
                Glyph { anchors.centerIn: parent; text: Icons.music; size: Theme.fontSmall; visible: Media.art === ""; color: Theme.subtext }
            }
            Label {
                text: Media.title
                width: Math.min(implicitWidth, 150)
                size: Theme.fontSmall + 0.5
                anchors.verticalCenter: parent.verticalCenter
            }
            EqBars { playing: Media.playing; anchors.verticalCenter: parent.verticalCenter }
        }

        // ── centre ──────────────────────────────────────────────────
        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter
            Label { text: Time.time; font.bold: true; size: Theme.fontUi + 1; anchors.verticalCenter: parent.verticalCenter }
            Label { text: Time.dateShort; color: Theme.subtext; anchors.verticalCenter: parent.verticalCenter }
        }

        // ── right wing ──────────────────────────────────────────────
        Chip { visible: Weather.ok; icon: Weather.icon; text: Weather.temp; tint: Theme.yellow; anchors.verticalCenter: parent.verticalCenter }
        Chip { icon: Icons.cpu; text: Math.round(Stats.cpu * 100) + "%"; tint: Stats.cpu > 0.85 ? Theme.red : Theme.subtext; anchors.verticalCenter: parent.verticalCenter }
        Chip { icon: Icons.memory; text: Math.round(Stats.mem * 100) + "%"; tint: Stats.mem > 0.85 ? Theme.red : Theme.subtext; anchors.verticalCenter: parent.verticalCenter }
        Chip { icon: Net.icon; text: Net.online ? Stats.human(Stats.rxRate) : ""; tint: Net.online ? Theme.subtext : Theme.red; anchors.verticalCenter: parent.verticalCenter }
        Chip { visible: Power.hasBattery; icon: Power.icon; text: Math.round(Power.percent * 100) + "%"
               tint: Power.charging ? Theme.green : Power.percent < 0.15 ? Theme.red : Theme.subtext; anchors.verticalCenter: parent.verticalCenter }

        // live activities
        Chip { visible: Recorder.recording; icon: Icons.record; text: Time.hms(Recorder.elapsed); tint: Theme.red; anchors.verticalCenter: parent.verticalCenter }
        Chip { visible: Timers.cdActive; icon: Icons.sand; text: Time.hms(Timers.cdLeft); tint: Theme.purple; anchors.verticalCenter: parent.verticalCenter }
        Chip { visible: Timers.swRunning; icon: Icons.timer; text: Time.hms(Timers.swMs / 1000); tint: Theme.purple; anchors.verticalCenter: parent.verticalCenter }
        Chip { visible: Session.inhibitIdle; icon: Icons.coffee; tint: Theme.yellow; anchors.verticalCenter: parent.verticalCenter }
        Chip { visible: Notifs.dnd; icon: Icons.bellOff; tint: Theme.red; anchors.verticalCenter: parent.verticalCenter }
        Chip { visible: !Notifs.dnd && Notifs.count > 0; icon: Icons.bell; text: Notifs.count; tint: Theme.accent; anchors.verticalCenter: parent.verticalCenter }
    }
}
