// SPDX-License-Identifier: GPL-3.0-or-later
// Lock-screen look. Accent follows the desktop theme (colors.json); the rest is
// fixed white-on-dark so it stays legible over any wallpaper.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var c: ({})
    readonly property color accent: c.accent ?? "#8aadf4"
    readonly property color red: "#e06c75"
    readonly property color text: "white"
    readonly property color subtext: Qt.rgba(1, 1, 1, 0.65)
    readonly property color faint: Qt.rgba(1, 1, 1, 0.45)
    readonly property color toolbar: Qt.rgba(0.06, 0.06, 0.06, 0.78)
    readonly property color toolbarHi: Qt.rgba(1, 1, 1, 0.10)
    readonly property string wallpaper: c.wallpaper ?? "/usr/share/hypr/wall2.png"
    readonly property string mono: "JetBrainsMono Nerd Font Mono"
    readonly property string font: "JetBrainsMono Nerd Font"

    function g(cp) { return String.fromCodePoint(cp) }
    readonly property string iLock:     g(0xF033E)
    readonly property string iKeyboard: g(0xF030C)
    readonly property string iArrow:    g(0xF0054)
    readonly property string iCoffee:   g(0xF0176)
    readonly property string iPower:    g(0xF0425)
    readonly property string iReboot:   g(0xF0709)
    readonly property string iSleep:    g(0xF0594)
    readonly property string iBolt:     g(0xF140B)
    readonly property string iBattery:  g(0xF0079)
    readonly property string iAccount:  g(0xF0009)

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/kessel/theme/colors.json"
        printErrors: false
        onLoaded: { try { root.c = JSON.parse(text()) } catch (e) {} }
    }
}
