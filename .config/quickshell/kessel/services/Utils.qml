// SPDX-License-Identifier: GPL-3.0-or-later
// One-shot tools launched from the island. Each closes the panel first so the
// tool sees the screen, not the island.
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property string scripts: Quickshell.env("HOME") + "/.config/hypr/scripts/"

    function later(cmd) {
        IslandState.closePanel()
        // small delay so the panel has animated away before grim/slurp/hyprpicker run
        Quickshell.execDetached(["sh", "-c", 'sleep 0.35; exec "$@"', "sh"].concat(cmd))
    }
    function screenshotRegion() { later([scripts + "screenshot.sh", "region"]) }
    function screenshotFull()   { later([scripts + "screenshot.sh", "full"]) }
    function colorPicker()      { later([scripts + "colorpicker.sh"]) }
    function recordRegion()     { IslandState.closePanel(); Recorder.toggle(true) }
    function recordScreen()     { IslandState.closePanel(); Recorder.toggle(false) }
}
