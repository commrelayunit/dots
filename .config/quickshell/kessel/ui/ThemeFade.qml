// SPDX-License-Identifier: GPL-3.0-or-later
// Theme crossfade for the whole screen. Apps like kitty, GTK and Qt can't animate
// their own colours, so while theme.sh switches, we show a frozen snapshot of the
// screen on top, then fade it out to reveal the new colours underneath.
// Click-through, and only exists while a switch is in progress.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"
import ".."

PanelWindow {
    id: fade
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "kessel-themefade"

    ScreencopyView {
        id: snap
        anchors.fill: parent
        captureSource: fade.screen
        live: false
        paintCursor: false
        opacity: 1
        NumberAnimation on opacity {
            id: out
            running: IslandState.thawing && snap.hasContent
            from: 1; to: 0
            duration: 650
            easing.type: Easing.InOutCubic
            onFinished: IslandState.fadeDone()
        }
    }
    // Nothing was captured (no screencopy support): don't leave the theme waiting.
    Timer { running: IslandState.thawing && !snap.hasContent; interval: 300; onTriggered: IslandState.fadeDone() }
}
