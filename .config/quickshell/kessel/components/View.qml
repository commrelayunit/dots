// SPDX-License-Identifier: GPL-3.0-or-later
// Base for island views: cross-fades in/out and is anchored at the top centre.
import QtQuick
import ".."

Item {
    property bool shown: false
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.94
    transformOrigin: Item.Top
    visible: opacity > 0.01
    Behavior on opacity { NumberAnimation { duration: Theme.fadeMs; easing.type: Easing.OutCubic } }
    Behavior on scale { SpringAnimation { spring: Theme.springStiffness * 1.2; damping: 0.45; epsilon: 0.002 } }
}
