// SPDX-License-Identifier: GPL-3.0-or-later
// Island arbitration + IPC. The island shows the highest layer that wants it:
//
//   panel         opened by the user (launcher, clipboard, control, power, timer)
//   notification  something arrived              until it expires / is closed
//   osd           volume changed                 briefly
//   summary       pointer resting on the island  until it leaves
//   rest          clock, workspaces and live activities
//
// IPC (used by Hyprland binds via scripts/island-or.sh):
//   qs -c kessel ipc call island open <launcher|clipboard|control|power|timer>
//   qs -c kessel ipc call island close | toggle | show | hide | dnd | record | status
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Singleton {
    id: root

    property bool shown: true
    property string panel: ""
    property bool hovered: false
    property bool summary: false

    property bool osdActive: false
    property string osdIcon: ""
    property string osdLabel: ""
    property real osdValue: 0

    readonly property var panels: ["launcher", "clipboard", "control", "notifications", "notes", "overview", "power", "timer", "wallpaper"]

    readonly property string layer: panel !== "" ? "panel"
        : Notifs.popup !== null ? "notification"
        : osdActive ? "osd"
        : summary ? "summary"
        : "rest"

    function openPanel(name) {
        if (panels.indexOf(name) < 0) return false
        shown = true
        panel = (panel === name) ? "" : name
        return true
    }
    function closePanel() { panel = "" }

    function showOsd(icon, label, value) {
        osdIcon = icon; osdLabel = label; osdValue = value
        osdActive = true
        osdTimer.restart()
    }

    Timer { id: osdTimer; interval: Config.osdMs; onTriggered: root.osdActive = false }
    // Hysteresis: open after the pointer rests, close only after it has been
    // gone for a moment (the pill changes size under the cursor while morphing).
    Timer { id: hoverTimer; interval: Config.hoverDelayMs; onTriggered: root.summary = root.hovered }
    Timer { id: leaveTimer; interval: 350; onTriggered: if (!root.hovered) root.summary = false }
    onHoveredChanged: {
        if (hovered) { leaveTimer.stop(); hoverTimer.restart() }
        else { hoverTimer.stop(); leaveTimer.restart() }
    }

    IpcHandler {
        target: "island"

        function open(name: string): string {
            if (!root.shown) return "hidden"
            return root.openPanel(name) ? "ok" : "unknown panel"
        }
        function close(): string { root.closePanel(); return "ok" }
        function toggle(): string { root.shown = !root.shown; if (!root.shown) root.closePanel(); return root.shown ? "shown" : "hidden" }
        function show(): string { root.shown = true; return "ok" }
        function hide(): string { root.shown = false; root.closePanel(); return "ok" }
        function dnd(): string { Notifs.dnd = !Notifs.dnd; return Notifs.dnd ? "dnd on" : "dnd off" }
        function record(): string { Recorder.toggle(false); return "ok" }
        function recordRegion(): string { Recorder.toggle(true); return "ok" }
        function layoutMode(mode: string): string {
            Session.floatMode = mode === "floating"
            root.showOsd(Session.floatMode ? Icons.floating : Icons.tiling, Session.floatMode ? "Floating" : "Tiling", 1)
            return "ok"
        }
        function reloadTheme(): string { Theme.reload(); return "ok" }
        function toggleTheme(): string { Themes.toggleMode(); return "ok" }
        function status(): string {
            return JSON.stringify({
                shown: root.shown, layer: root.layer, panel: root.panel,
                dnd: Notifs.dnd, notifications: Notifs.count,
                media: Media.active ? Media.title : null,
                recording: Recorder.recording, weather: Weather.ok ? Weather.temp : null
            })
        }
    }
}
