// SPDX-License-Identifier: GPL-3.0-or-later
// Notifications overview (SUPER+N): every notification, click to focus, × to dismiss;
// with today's calendar and the weather beside it.
import QtQuick
import "../.."
import "../../services"
import "../../components"

PanelBase {
    id: root
    title: Notifs.count > 0 ? `Notifications · ${Notifs.count}` : "Notifications"
    icon: Icons.bell
    contentWidth: 760
    contentHeight: Math.max(list.height, side.height)

    headerExtra: [
        IconButton { icon: Notifs.dnd ? Icons.bellOff : Icons.bell; active: Notifs.dnd; tint: Theme.red; size: 26; iconSize: Theme.fontSmall + 2; onClicked: Notifs.dnd = !Notifs.dnd },
        IconButton { icon: Icons.trash; size: 26; iconSize: Theme.fontSmall + 2; onClicked: Notifs.clearAll() }
    ]

    ListView {
        id: list
        width: 420
        height: Math.min(520, Math.max(120, contentHeight))
        clip: true
        spacing: 8
        boundsBehavior: Flickable.StopAtBounds
        model: Notifs.list.slice().reverse()     // newest first
        delegate: NotificationCard {
            required property var modelData
            notif: modelData
            inList: true
            width: list.width
        }
        add: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 160 } }
        displaced: Transition { NumberAnimation { properties: "y"; duration: 160 } }
        Column {
            anchors.centerIn: parent
            visible: list.count === 0
            spacing: 6
            Glyph { text: Icons.bell; size: 26; color: Theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
            Label { text: Notifs.dnd ? "Do not disturb is on" : "You're all caught up"; color: Theme.subtext }
        }
    }

    Column {
        id: side
        x: 440
        width: 320
        spacing: 12

        Rectangle {
            width: parent.width
            height: cal.height + 20
            radius: Theme.radiusCard
            color: Theme.card
            Calendar { id: cal; x: 10; y: 10; width: parent.width - 20 }
        }

        Rectangle {
            visible: Weather.ok
            width: parent.width
            height: wcol.height + 20
            radius: Theme.radiusCard
            color: Theme.card
            Column {
                id: wcol
                x: 14; y: 10
                width: parent.width - 28
                spacing: 6
                Row {
                    spacing: 10
                    Glyph { text: Weather.icon; size: 26; color: Theme.yellow }
                    Column {
                        Label { text: `${Weather.temp}  ${Weather.desc}`; font.bold: true }
                        Label { text: `Feels ${Weather.feels} · ${Weather.area}`; color: Theme.subtext; size: Theme.fontSmall }
                    }
                }
                Row {
                    spacing: 14
                    Chip { icon: Icons.drop; text: Weather.humidity }
                    Chip { icon: Icons.wind; text: Weather.wind }
                }
                Row {
                    spacing: 18
                    Repeater {
                        model: Weather.forecast
                        Column {
                            required property var modelData
                            spacing: 2
                            Label { text: modelData.day; size: Theme.fontSmall; color: Theme.subtext; anchors.horizontalCenter: parent.horizontalCenter }
                            Glyph { text: Weather.iconFor(modelData.code, 12); color: Theme.yellow; anchors.horizontalCenter: parent.horizontalCenter }
                            Label { text: `${modelData.max} ${modelData.min}`; size: Theme.fontSmall; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }
                }
            }
        }
    }
}
