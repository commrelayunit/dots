// SPDX-License-Identifier: GPL-3.0-or-later
// A restrained top-centre pill: clock, with the long date when expanded.
import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../services"

PanelWindow {
    id: win
    visible: IslandState.shown

    anchors.top: true
    margins.top: Theme.islandMargin
    // Fixed-width transparent surface (resizing a layer surface mid-animation clips);
    // only the pill itself receives input.
    implicitWidth: 560
    mask: Region { item: pill }
    implicitHeight: Theme.islandHeight
    exclusiveZone: Theme.islandHeight + Theme.islandMargin
    color: "transparent"

    WlrLayershell.namespace: "kessel-island"
    WlrLayershell.layer: WlrLayer.Top

    Rectangle {
        id: pill
        anchors.centerIn: parent
        height: Theme.islandHeight
        width: content.implicitWidth + 32
        radius: Theme.radius
        color: Qt.rgba(0.106, 0.118, 0.153, 0.92)   // Theme.surface @ 92%
        border.width: 1
        border.color: hover.hovered ? Theme.accent : Theme.overlay

        Behavior on width { NumberAnimation { duration: Theme.animMs; easing.type: Easing.OutCubic } }
        Behavior on border.color { ColorAnimation { duration: Theme.animMs } }

        ClockView {
            id: content
            anchors.centerIn: parent
            expanded: IslandState.expanded
        }

        HoverHandler { id: hover }
        TapHandler { onTapped: IslandState.expanded = !IslandState.expanded }
    }
}
