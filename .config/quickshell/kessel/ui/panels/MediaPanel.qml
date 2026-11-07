// SPDX-License-Identifier: GPL-3.0-or-later
// Media player (SUPER+M), Material-style: blurred cover backdrop, large art,
// title / artist / album, seekable progress, shuffle · prev · play · next · loop,
// and a switcher when several players are open.
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris
import "../.."
import "../../services"
import "../../components"

PanelBase {
    id: root
    title: Media.active ? Media.identity : "Media"
    icon: Icons.music
    contentWidth: 560
    contentHeight: Media.active ? 236 + (Media.players.length > 1 ? 44 : 0) : 120

    focus: true
    Keys.onSpacePressed: Media.toggle()
    Keys.onRightPressed: Media.next()
    Keys.onLeftPressed: Media.prev()

    // nothing playing
    Column {
        visible: !Media.active
        anchors.centerIn: parent
        spacing: 8
        Glyph { text: Icons.music; size: 26; color: Theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
        Label { text: "No media player is open"; color: Theme.subtext; anchors.horizontalCenter: parent.horizontalCenter }
    }

    Item {
        visible: Media.active
        anchors.fill: parent

        // blurred cover backdrop
        Rectangle {
            id: card
            width: parent.width
            height: 236
            radius: Theme.radiusPanel - 6
            color: Theme.card
            clip: true
            Image {
                id: bgArt
                anchors.fill: parent
                source: Media.art
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: false
            }
            MultiEffect {
                anchors.fill: parent
                source: bgArt
                visible: bgArt.status === Image.Ready
                blurEnabled: true
                blurMax: 64
                blur: 1.0
                opacity: 0.45
                saturation: 0.2
            }
            Rectangle { anchors.fill: parent; color: Theme.a(Theme.base, 0.35) }

            // cover
            Rectangle {
                id: cover
                x: 20
                anchors.verticalCenter: parent.verticalCenter
                width: 190; height: 190
                radius: 22
                color: Theme.overlay
                clip: true
                Image { anchors.fill: parent; source: Media.art; fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize: Qt.size(380, 380) }
                Glyph { anchors.centerIn: parent; text: Icons.album; size: 48; color: Theme.subtext; visible: Media.art === "" }
                layer.enabled: true
                layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 0.8; shadowOpacity: 0.5; shadowVerticalOffset: 6 }
            }

            Column {
                anchors.left: cover.right
                anchors.leftMargin: 22
                anchors.right: parent.right
                anchors.rightMargin: 22
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Label { text: Media.title; font.bold: true; size: Theme.fontUi + 4; width: parent.width }
                Label { text: Media.artist; color: Theme.text; size: Theme.fontUi; width: parent.width; visible: text !== "" }
                Label { text: Media.album; color: Theme.subtext; size: Theme.fontSmall; width: parent.width; visible: text !== "" }

                Item { width: 1; height: 10 }

                Bar {
                    width: parent.width
                    value: Media.progress
                    interactive: Media.player?.canSeek ?? false
                    thickness: 6
                    fill: Theme.accent
                    onMoved: v => Media.seekTo(v)
                }
                Item {
                    width: parent.width
                    height: 16
                    Label { text: Time.hms(Media.position); size: Theme.fontSmall - 0.5; color: Theme.subtext }
                    Label { anchors.right: parent.right; text: Media.length > 0 ? Time.hms(Media.length) : "–"; size: Theme.fontSmall - 0.5; color: Theme.subtext }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    IconButton { icon: Media.shuffle ? Icons.shuffleOn : Icons.shuffleOff; size: 34; active: Media.shuffle
                                 visible: Media.player?.shuffleSupported ?? false; anchors.verticalCenter: parent.verticalCenter; onClicked: Media.toggleShuffle() }
                    IconButton { icon: Icons.prev; size: 40; iconSize: Theme.fontUi + 6; anchors.verticalCenter: parent.verticalCenter; onClicked: Media.prev() }
                    // big Material-style play button: a rounded square that becomes a circle when playing
                    Rectangle {
                        width: 60; height: 60
                        radius: Media.playing ? 30 : 18
                        color: Theme.accent
                        Behavior on radius { SpringAnimation { spring: Theme.springStiffness; damping: 0.4; epsilon: 0.2 } }
                        Glyph { anchors.centerIn: parent; optical: true; text: Media.playing ? Icons.pause : Icons.play; size: Theme.fontUi + 12; color: Theme.base }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Media.toggle() }
                    }
                    IconButton { icon: Icons.next; size: 40; iconSize: Theme.fontUi + 6; anchors.verticalCenter: parent.verticalCenter; onClicked: Media.next() }
                    IconButton { icon: Media.loop === MprisLoopState.Track ? Icons.repeatOne : Media.loop === MprisLoopState.Playlist ? Icons.repeatAll : Icons.repeatOff
                                 size: 34; active: Media.loop !== MprisLoopState.None
                                 visible: Media.player?.loopSupported ?? false; anchors.verticalCenter: parent.verticalCenter; onClicked: Media.cycleLoop() }
                }
            }
        }

        // player switcher
        Row {
            visible: Media.players.length > 1
            anchors.top: card.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            Repeater {
                model: Media.players
                Rectangle {
                    required property var modelData
                    readonly property bool on: modelData === Media.player
                    width: pl.implicitWidth + 24; height: 30; radius: 15
                    color: on ? Theme.a(Theme.accent, 0.22) : (pma.containsMouse ? Theme.cardHi : Theme.card)
                    Label { id: pl; anchors.centerIn: parent; text: modelData.identity || "Player"; size: Theme.fontSmall; color: parent.on ? Theme.accent : Theme.text }
                    MouseArea { id: pma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Media.chosen = modelData }
                }
            }
        }
    }
}
