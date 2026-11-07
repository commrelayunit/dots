// SPDX-License-Identifier: GPL-3.0-or-later
// Shared look: Kessel palette + JetBrainsMono Nerd Font (UI 11 / mono 12, see docs/THEME.md).
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    // Colours come from ~/.local/state/kessel/theme/colors.json, written by
    // ~/.config/hypr/scripts/theme.sh (dark = pitch black, light = eggshell,
    // accents from the wallpaper). Watched live; defaults = dark.
    property var c: ({})
    readonly property bool dark: (c.mode ?? "dark") !== "light"

    readonly property color base:    c.bg ?? "#000000"
    readonly property color surface: c.surface ?? "#0b0b0b"
    readonly property color overlay: c.overlay ?? "#262626"
    readonly property color muted:   c.muted ?? "#5a5a5a"
    readonly property color text:    c.text ?? "#e8e8e8"
    readonly property color subtext: c.subtext ?? "#9a9a9a"
    readonly property color accent:  c.accent ?? "#8aadf4"
    readonly property color accent2: c.accent2 ?? "#a6da95"
    readonly property color accent3: c.accent3 ?? "#c6a0f6"
    readonly property color green:   c.green ?? "#a6da95"
    readonly property color red:     c.red ?? "#e06c75"
    readonly property color yellow:  c.yellow ?? "#eed49f"
    readonly property color purple:  c.purple ?? "#c6a0f6"

    // The island is the mode's base colour, nearly opaque.
    readonly property color island:  a(base, dark ? 0.97 : 0.96)
    readonly property color card:    a(text, dark ? 0.06 : 0.06)
    readonly property color cardHi:  a(text, dark ? 0.11 : 0.10)

    function reload() { colorsFile.reload() }

    FileView {
        id: colorsFile
        path: Quickshell.env("HOME") + "/.local/state/kessel/theme/colors.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: { try { root.c = JSON.parse(text()) } catch (e) { console.warn("theme: bad colors.json") } }
    }

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

    // Physics-based morphing (Qt SpringAnimation). Slightly under-damped like
    // macOS/iOS: a hint of overshoot, then it settles. Velocity is preserved when
    // the target changes mid-flight, so interrupted morphs stay smooth.
    readonly property real springStiffness: 3.6     // higher = snappier
    readonly property real springDamping: 0.32      // lower = more bounce (0.2…0.5 sensible)
    readonly property real springMass: 1.0
    readonly property int fadeMs: 160

    function a(c, alpha) { return Qt.rgba(c.r, c.g, c.b, alpha) }
}
