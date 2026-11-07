// SPDX-License-Identifier: GPL-3.0-or-later
// Base for island views: cross-fades in/out and is anchored at the top centre.
import QtQuick
import ".."

Item {
    property bool shown: false
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    opacity: shown ? 1 : 0
    visible: opacity > 0.01
    Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
}
