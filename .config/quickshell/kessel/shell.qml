// SPDX-License-Identifier: GPL-3.0-or-later
// Kessel — dynamic island. Run: qs -c kessel
// Optional by design: Hyprland, kitty and fuzzel never depend on this.
import QtQuick
import Quickshell
import "ui"
import "services"

ShellRoot {
    Variants {
        model: Quickshell.screens
        Island {
            required property var modelData
            screen: modelData
        }
    }

    // Instantiate services that must run even before any UI reads them.
    Component.onCompleted: {
        IslandState.shown = true
        void Notifs.count
        void Audio.ready
    }
}
