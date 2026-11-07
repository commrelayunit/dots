// SPDX-License-Identifier: GPL-3.0-or-later
// Light/dark + wallpaper, delegated to ~/.config/hypr/scripts/theme.sh.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Singleton {
    id: root
    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/scripts/theme.sh"
    readonly property string wallDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    readonly property string current: Theme.c.wallpaper ?? ""
    property var wallpapers: []
    property bool busy: false

    function toggleMode() { run(["mode", "toggle"]) }
    function setMode(m) { run(["mode", m]) }
    function setWallpaper(path) { run(["wallpaper", path]) }
    function run(args) {
        busy = true
        proc.command = [script].concat(args)
        proc.running = true
    }
    Process { id: proc; onExited: root.busy = false }

    function refresh() { if (!lister.running) lister.running = true }
    Process {
        id: lister
        command: ["sh", "-c", 'mkdir -p "$1"; f() { find -L "$@" -maxdepth 2 -type f \\( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \\) ! -iname "*lock*" 2>/dev/null | sort; }; l="$(f "$1")"; [ -n "$l" ] && echo "$l" || f /usr/share/hypr', "sh", root.wallDir]
        stdout: StdioCollector { onStreamFinished: root.wallpapers = text.split("\n").filter(l => l !== "") }
    }
}
