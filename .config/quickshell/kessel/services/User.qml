// SPDX-License-Identifier: GPL-3.0-or-later
// Logged-in user: name, host, avatar (~/.face), uptime.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property string name: Quickshell.env("USER") || "user"
    property string realName: ""
    property string host: ""
    property real uptimeSec: 0
    readonly property string face: Quickshell.env("HOME") + "/.face"
    property bool hasFace: false
    readonly property string uptime: {
        const s = Math.floor(uptimeSec), d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60)
        return (d > 0 ? d + "d " : "") + (h > 0 ? h + "h " : "") + m + "m"
    }

    Process {
        id: probe
        running: true
        command: ["sh", "-c", 'cat /etc/hostname 2>/dev/null; getent passwd "$USER" | cut -d: -f5 | cut -d, -f1; cut -d" " -f1 /proc/uptime; [ -s "$HOME/.face" ] && echo face']
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.split("\n")
                root.host = (l[0] || "").trim()
                root.realName = (l[1] || "").trim()
                root.uptimeSec = parseFloat(l[2]) || 0
                root.hasFace = (l[3] || "").trim() === "face"
            }
        }
    }
    Timer { interval: 60000; running: true; repeat: true; onTriggered: probe.running = true }
}
