// SPDX-License-Identifier: GPL-3.0-or-later
// Volume mixer (SUPER+SHIFT+V): output + microphone with device pickers, and
// per-app volume / mute for everything currently playing.
import QtQuick
import Quickshell
import "../.."
import "../../services"
import "../../components"

PanelBase {
    id: root
    title: "Mixer"
    icon: Icons.volHigh
    contentWidth: 520
    contentHeight: col.implicitHeight

    headerExtra: IconButton { icon: Icons.settings; size: 26; iconSize: Theme.fontSmall + 2
                              onClicked: { IslandState.closePanel(); Quickshell.execDetached(["pavucontrol"]) } }

    Column {
        id: col
        width: parent.width
        spacing: 8

        SectionRow {
            visible: !Audio.ready
            width: parent.width
            icon: Icons.volOff
            title: "Audio"
            sub: "No audio device"
        }
        SliderRow {
            width: parent.width
            visible: Audio.ready
            icon: Audio.icon
            title: "Output · " + Audio.sinkName
            value: Audio.volume
            muted: Audio.muted
            expandable: Audio.sinks.length > 1
            onMoved: v => Audio.setVolume(v)
            onIconClicked: Audio.toggleMute()
            Repeater {
                model: Audio.sinks
                ListItem {
                    required property var modelData
                    icon: Icons.speaker
                    text: Audio.label(modelData, "Output")
                    selected: modelData === Audio.sink
                    onClicked: Audio.setSink(modelData)
                }
            }
        }
        SliderRow {
            width: parent.width
            visible: Audio.micReady
            icon: Audio.micIcon
            title: "Microphone · " + Audio.sourceName
            value: Audio.micVolume
            muted: Audio.micMuted
            tint: Theme.purple
            expandable: Audio.sources.length > 1
            onMoved: v => Audio.setMicVolume(v)
            onIconClicked: Audio.toggleMicMute()
            Repeater {
                model: Audio.sources
                ListItem {
                    required property var modelData
                    icon: Icons.mic
                    text: Audio.label(modelData, "Input")
                    selected: modelData === Audio.source
                    onClicked: Audio.setSource(modelData)
                }
            }
        }

        Label { text: "Apps"; color: Theme.subtext; size: Theme.fontSmall; topPadding: 6; leftPadding: 4 }
        Repeater {
            model: Audio.streams
            Rectangle {
                id: app
                required property var modelData
                readonly property bool muted: modelData.audio?.muted ?? false
                width: col.width
                height: 62
                radius: Theme.radiusCard
                color: Theme.card
                Image {
                    id: appIcon
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28; height: 28
                    sourceSize: Qt.size(56, 56)
                    source: Quickshell.iconPath(Audio.appIcon(app.modelData), "audio-x-generic")
                }
                Column {
                    anchors.left: appIcon.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Row {
                        width: parent.width
                        spacing: 6
                        Label { text: Audio.appName(app.modelData); font.bold: true; size: Theme.fontSmall + 0.5 }
                        Label { text: Audio.mediaName(app.modelData); color: Theme.subtext; size: Theme.fontSmall - 0.5; width: parent.width - 140 }
                    }
                    Row {
                        width: parent.width
                        spacing: 8
                        IconButton { icon: app.muted ? Icons.volOff : Icons.volHigh; size: 24; iconSize: Theme.fontSmall + 1; active: !app.muted; onClicked: Audio.toggleStreamMute(app.modelData) }
                        Bar {
                            width: parent.width - 80
                            anchors.verticalCenter: parent.verticalCenter
                            value: app.muted ? 0 : (app.modelData.audio?.volume ?? 0)
                            interactive: true
                            fill: app.muted ? Theme.muted : Theme.accent
                            onMoved: v => Audio.setStreamVolume(app.modelData, v)
                        }
                        Label { text: app.muted ? "off" : Math.round((app.modelData.audio?.volume ?? 0) * 100) + "%"; size: Theme.fontSmall; color: Theme.subtext; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
        }
        Label {
            visible: Audio.streams.length === 0
            width: col.width
            horizontalAlignment: Text.AlignHCenter
            text: "Nothing is playing"
            color: Theme.muted
            size: Theme.fontSmall
            topPadding: 8; bottomPadding: 8
        }
    }
}
