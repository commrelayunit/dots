// SPDX-License-Identifier: GPL-3.0-or-later
// Rounded screen corners (end-4 style): four click-through black quarter-rounds.
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import ".."

Scope {
    id: root
    required property var screen
    readonly property int r: Theme.screenCornerRadius

    component Corner: PanelWindow {
        id: c
        property bool top: true
        property bool left: true
        screen: root.screen
        anchors.top: top
        anchors.bottom: !top
        anchors.left: left
        anchors.right: !left
        implicitWidth: root.r
        implicitHeight: root.r
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        mask: Region {}                           // click-through
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "kessel-corner"
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: 0
                fillColor: "black"
                // fill the corner square minus a quarter circle centred on the inner corner
                startX: c.left ? 0 : root.r; startY: c.top ? 0 : root.r
                PathLine { x: c.left ? root.r : 0; y: c.top ? 0 : root.r }
                PathArc {
                    x: c.left ? 0 : root.r; y: c.top ? root.r : 0
                    radiusX: root.r; radiusY: root.r
                    direction: (c.left === c.top) ? PathArc.Counterclockwise : PathArc.Clockwise
                }
                PathLine { x: c.left ? 0 : root.r; y: c.top ? 0 : root.r }
            }
        }
    }
    Corner { top: true;  left: true }
    Corner { top: true;  left: false }
    Corner { top: false; left: true }
    Corner { top: false; left: false }
}
