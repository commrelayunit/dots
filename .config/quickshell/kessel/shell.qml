// SPDX-License-Identifier: GPL-3.0-or-later
// Kessel — minimal Quickshell island. Run: qs -c kessel
// Optional by design: Hyprland, kitty and fuzzel never depend on this.
import QtQuick
import Quickshell
import "ui"
import "services"

ShellRoot {
    // One island per screen.
    Variants {
        model: Quickshell.screens
        Island {
            required property var modelData
            screen: modelData
        }
    }

    // Keep the IPC handler alive for the life of the shell.
    Component.onCompleted: IslandState.ready = true
}
