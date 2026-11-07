// SPDX-License-Identifier: GPL-3.0-or-later
// Countdown timer + stopwatch (SUPER+T). Both keep running when the panel closes.
import QtQuick
import "../.."
import "../../services"
import "../../components"

PanelBase {
    id: root
    title: "Timer"
    icon: Icons.sand
    contentWidth: 520
    contentHeight: 190
    property int custom: 15

    Row {
        spacing: 12
        Rectangle {
            width: 254; height: 190; radius: Theme.radiusCard; color: Theme.card
            Column {
                anchors.centerIn: parent
                spacing: 10
                Label { text: "Countdown"; color: Theme.subtext; size: Theme.fontSmall; anchors.horizontalCenter: parent.horizontalCenter }
                Label { text: Time.hms(Timers.cdActive ? Timers.cdLeft : root.custom * 60); size: Theme.fontBig; font.bold: true; color: Timers.cdActive ? Theme.purple : Theme.text; anchors.horizontalCenter: parent.horizontalCenter }
                Row {
                    visible: !Timers.cdActive
                    spacing: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    IconButton { icon: Icons.minus; size: 26; onClicked: root.custom = Math.max(1, root.custom - 1) }
                    Repeater {
                        model: Config.timerPresets
                        Rectangle {
                            required property int modelData
                            width: 32; height: 26; radius: 13
                            color: root.custom === modelData ? Theme.a(Theme.purple, 0.25) : Theme.cardHi
                            Label { anchors.centerIn: parent; text: modelData; size: Theme.fontSmall }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.custom = modelData }
                        }
                    }
                    IconButton { icon: Icons.plus; size: 26; onClicked: root.custom = Math.min(600, root.custom + 1) }
                }
                Row {
                    spacing: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    IconButton { icon: Timers.cdRunning ? Icons.pause : Icons.play; size: 36; active: true; tint: Theme.purple
                                 onClicked: Timers.cdActive ? Timers.pauseCountdown() : Timers.startCountdown(root.custom) }
                    IconButton { icon: Icons.stop; size: 36; visible: Timers.cdActive; onClicked: Timers.cancelCountdown() }
                }
            }
        }
        Rectangle {
            width: 254; height: 190; radius: Theme.radiusCard; color: Theme.card
            Column {
                anchors.centerIn: parent
                spacing: 14
                Label { text: "Stopwatch"; color: Theme.subtext; size: Theme.fontSmall; anchors.horizontalCenter: parent.horizontalCenter }
                Label {
                    text: Time.hms(Timers.swMs / 1000) + "." + Math.floor(Timers.swMs % 1000 / 100)
                    size: Theme.fontBig; font.bold: true
                    color: Timers.swRunning ? Theme.purple : Theme.text
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Row {
                    spacing: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    IconButton { icon: Timers.swRunning ? Icons.pause : Icons.play; size: 36; active: true; tint: Theme.purple; onClicked: Timers.swToggle() }
                    IconButton { icon: Icons.restart; size: 36; onClicked: Timers.swReset() }
                }
            }
        }
    }
}
