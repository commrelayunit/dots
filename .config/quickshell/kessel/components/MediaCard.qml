// SPDX-License-Identifier: GPL-3.0-or-later
// Music controller: art, title/artist, seekable progress, transport.
import QtQuick
import ".."
import "../services"

Rectangle {
    id: root
    property bool compact: false
    implicitWidth: 400
    implicitHeight: compact ? 86 : 104
    radius: Theme.radiusCard
    color: Theme.card

    Rectangle {
        id: art
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: root.implicitHeight - 24
        height: width
        radius: 10
        color: Theme.overlay
        clip: true
        Image { anchors.fill: parent; source: Media.art; fillMode: Image.PreserveAspectCrop; asynchronous: true }
        Glyph { anchors.centerIn: parent; text: Icons.music; size: 20; color: Theme.subtext; visible: Media.art === "" }
    }

    Column {
        anchors.left: art.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Label { text: Media.title; font.bold: true; width: parent.width }
        Label { text: Media.artist || Media.identity; color: Theme.subtext; size: Theme.fontSmall; width: parent.width }
        Row {
            width: parent.width
            spacing: 8
            Label { text: Time.hms(Media.position); size: Theme.fontSmall; color: Theme.subtext; anchors.verticalCenter: parent.verticalCenter }
            Bar {
                width: parent.width - 100
                anchors.verticalCenter: parent.verticalCenter
                value: Media.progress
                interactive: Media.player?.canSeek ?? false
                thickness: 4
                fill: Theme.green
                onMoved: v => Media.seekTo(v)
            }
            Label { text: Media.length > 0 ? Time.hms(Media.length) : "–"; size: Theme.fontSmall; color: Theme.subtext; anchors.verticalCenter: parent.verticalCenter }
        }
        Row {
            spacing: 6
            anchors.horizontalCenter: parent.horizontalCenter
            IconButton { icon: Icons.prev; size: 28; onClicked: Media.prev() }
            IconButton { icon: Media.playing ? Icons.pause : Icons.play; size: 32; iconSize: Theme.fontUi + 6; active: true; tint: Theme.green; onClicked: Media.toggle() }
            IconButton { icon: Icons.next; size: 28; onClicked: Media.next() }
        }
    }
}
