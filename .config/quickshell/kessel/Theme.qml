// SPDX-License-Identifier: GPL-3.0-or-later
// Shared look: Kessel palette + JetBrainsMono Nerd Font (UI 11 / mono 12, see docs/THEME.md).
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property color base:    "#11131a"
    readonly property color surface: "#1b1e27"
    readonly property color overlay: "#2a2e3a"
    readonly property color muted:   "#4a5063"
    readonly property color text:    "#d8dae1"
    readonly property color subtext: "#8b90a0"
    readonly property color accent:  "#8aadf4"
    readonly property color green:   "#a6da95"
    readonly property color red:     "#e06c75"
    readonly property color yellow:  "#eed49f"
    readonly property color purple:  "#c6a0f6"

    // The island is near-black so it reads as one object over any wallpaper.
    readonly property color island:  Qt.rgba(0.043, 0.047, 0.063, 0.96)
    readonly property color card:    Qt.rgba(1, 1, 1, 0.045)
    readonly property color cardHi:  Qt.rgba(1, 1, 1, 0.09)

    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property real fontUi: 11
    readonly property real fontMono: 12
    readonly property real fontSmall: 9.5
    readonly property real fontBig: 22

    readonly property int islandHeight: 36
    readonly property int islandMargin: 6
    readonly property int radius: 18
    readonly property int radiusPanel: 26
    readonly property int radiusCard: 14
    readonly property int pad: 14

    readonly property int animMs: 320
    readonly property int fadeMs: 160

    function a(c, alpha) { return Qt.rgba(c.r, c.g, c.b, alpha) }
}
