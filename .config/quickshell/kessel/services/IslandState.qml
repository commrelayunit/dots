// SPDX-License-Identifier: GPL-3.0-or-later
// Island state + IPC. Hyprland binds / scripts call e.g.:
//   qs -c kessel ipc call island toggle
//   qs -c kessel ipc call island toggleExpanded
//   qs -c kessel ipc call island status
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool ready: false
    property bool shown: true
    property bool expanded: false

    IpcHandler {
        target: "island"

        function toggle(): void { root.shown = !root.shown }
        function show(): void { root.shown = true }
        function hide(): void { root.shown = false }
        function toggleExpanded(): void { root.expanded = !root.expanded }
        function status(): string {
            return JSON.stringify({ shown: root.shown, expanded: root.expanded })
        }
    }
}
