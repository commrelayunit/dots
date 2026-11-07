// SPDX-License-Identifier: GPL-3.0-or-later
// Pending package updates: official (checkupdates — uses a temporary database,
// never touches pacman's own) + AUR (yay -Qua). Checked a minute after start,
// then hourly. Clicking the pill opens kitty with ~/Scripts/update.sh.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property int official: 0
    property int aur: 0
    readonly property int count: official + aur
    property var names: []
    property bool checking: false
    property real lastCheck: 0

    function check() {
        if (proc.running) return
        checking = true
        proc.running = true
    }
    Process {
        id: proc
        command: ["sh", "-c", 'o="$(checkupdates 2>/dev/null)"; a=""; command -v yay >/dev/null && a="$(yay -Qua 2>/dev/null)"; printf "%s\\n" "$o" | grep -c . ; printf "%s\\n" "$a" | grep -c . ; printf "%s\\n%s\\n" "$o" "$a" | awk "NF{print \\$1}" | head -12']
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.split("\n")
                root.official = parseInt(l[0]) || 0
                root.aur = parseInt(l[1]) || 0
                root.names = l.slice(2).filter(s => s !== "")
                root.checking = false
                root.lastCheck = Date.now()
            }
        }
    }
    Timer { interval: 60000; running: true; onTriggered: root.check() }          // first check after boot settles
    Timer { interval: 3600000; running: true; repeat: true; onTriggered: root.check() }

    function runUpdate() {
        IslandState.closePanel()
        Quickshell.execDetached(["kitty", "--class", "kessel-update", "--title", "System update", "fish", "-c",
            '~/Scripts/update.sh --aur; qs -c kessel ipc call island updatesCheck >/dev/null 2>&1; read -P "Done — press Enter to close "'])
    }
}
