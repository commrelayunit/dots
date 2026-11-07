// SPDX-License-Identifier: GPL-3.0-or-later
// Backlight via brightnessctl. Hidden when there is no /sys/class/backlight device (VMs, desktops).
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Singleton {
    id: root
    property bool available: false
    property real value: 0      // 0..1
    property int _max: 1

    function refresh() { if (!probe.running) probe.running = true }
    function set(v) {
        if (!available) return
        v = Math.max(0.01, Math.min(1, v))
        value = v
        Quickshell.execDetached(["brightnessctl", "-q", "set", Math.round(v * 100) + "%"])
        IslandState.showOsd(Icons.brightness, Math.round(v * 100) + "%", v)
    }

    // brightnessctl -m → "device,class,current,percent,max"
    Process {
        id: probe
        running: true
        command: ["sh", "-c", "ls /sys/class/backlight/ 2>/dev/null | grep -q . && command -v brightnessctl >/dev/null && brightnessctl -m -c backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",")
                if (f.length >= 5) {
                    root.available = true
                    root._max = parseInt(f[4]) || 1
                    root.value = (parseInt(f[2]) || 0) / root._max
                }
            }
        }
    }
}
