// SPDX-License-Identifier: GPL-3.0-or-later
// Shared look: Kessel palette + JetBrainsMono Nerd Font (UI 11 / mono 12, see docs/THEME.md).
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property color base:    "#11131a"
    readonly property color surface: "#1b1e27"
    readonly property color overlay: "#2a2e3a"
    readonly property color text:    "#d8dae1"
    readonly property color subtext: "#8b90a0"
    readonly property color accent:  "#8aadf4"

    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property real fontUi: 11
    readonly property real fontMono: 12

    readonly property int islandHeight: 34
    readonly property int islandMargin: 8
    readonly property int radius: 17
    readonly property int animMs: 180
}
