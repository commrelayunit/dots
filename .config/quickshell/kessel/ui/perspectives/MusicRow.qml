// SPDX-License-Identifier: GPL-3.0-or-later
// Music perspective: spinning art · scrolling title/artist · cava visualizer ·
// time left · play/pause; a progress line runs along the pill's bottom edge
// (drawn by RestView). Bars rest as a dot row when paused (dot-matrix idle).
import QtQuick
import Quickshell
import "../.."
import "../../services"
import "../../components"

Item {
    id: root
    property bool active: false
    implicitWidth: row.implicitWidth
    implicitHeight: Theme.islandHeight

    // the visualizer only runs while this perspective is on screen and playing
    Binding { target: Cava; property: "wanted"; value: root.active && Media.playing }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Rectangle {
            id: art
            width: 24; height: 24; radius: 12
            color: Theme.overlay
            clip: true
            anchors.verticalCenter: parent.verticalCenter
            Image { anchors.fill: parent; source: Media.art; fillMode: Image.PreserveAspectCrop; asynchronous: true; visible: status === Image.Ready }
            Glyph { anchors.centerIn: parent; optical: true; text: Icons.music; size: Theme.fontSmall; color: Theme.subtext; visible: Media.art === "" }
            RotationAnimation on rotation { running: Media.playing; from: 0; to: 360; duration: 12000; loops: Animation.Infinite }
        }

        // marquee: scrolls when "title — artist" is wider than its box
        Item {
            id: marquee
            width: 180
            height: Theme.islandHeight
            clip: true
            anchors.verticalCenter: parent.verticalCenter
            readonly property string full: Media.title + (Media.artist ? "  ·  " + Media.artist : "")
            Label {
                id: mtext
                y: (parent.height - height) / 2
                text: marquee.full + (overflow ? "        " + marquee.full : "")
                readonly property bool overflow: tm.advanceWidth > marquee.width
                size: Theme.fontSmall + 0.5
                elide: Text.ElideNone
                TextMetrics { id: tm; font: mtext.font; text: marquee.full }
                NumberAnimation on x {
                    running: mtext.overflow && root.active
                    from: 0; to: -(tm.advanceWidth + tm.font.pointSize * 6)
                    duration: Math.max(6000, tm.advanceWidth * 28)
                    loops: Animation.Infinite
                }
                onOverflowChanged: if (!overflow) x = 0
            }
        }

        // visualizer
        Row {
            id: viz
            spacing: 2
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            Repeater {
                model: Cava.bars
                Rectangle {
                    required property int index
                    readonly property real v: Media.playing ? (Cava.values[index] ?? 0) : 0
                    width: 3
                    height: Math.max(3, v * viz.height)
                    radius: 1.5
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(Theme.accent.r + (Theme.accent3.r - Theme.accent.r) * index / Cava.bars,
                                   Theme.accent.g + (Theme.accent3.g - Theme.accent.g) * index / Cava.bars,
                                   Theme.accent.b + (Theme.accent3.b - Theme.accent.b) * index / Cava.bars, 1)
                    opacity: Media.playing ? 0.55 + 0.45 * v : 0.35
                    Behavior on height { NumberAnimation { duration: 60 } }
                }
            }
        }

        Label {
            width: 46
            horizontalAlignment: Text.AlignRight
            text: Media.length > 0 ? "-" + Time.hms(Media.length - Media.position) : ""
            color: Theme.subtext
            size: Theme.fontSmall
            anchors.verticalCenter: parent.verticalCenter
        }
        IconButton {
            icon: Media.playing ? Icons.pause : Icons.play
            size: 26
            iconSize: Theme.fontUi
            onClicked: Media.toggle()
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
