// SPDX-License-Identifier: GPL-3.0-or-later
// CPU / RAM / network throughput from /proc, sampled every 2 s.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpu: 0          // 0..1
    property real mem: 0          // 0..1
    property real memUsedGiB: 0
    property real memTotalGiB: 0
    property real rxRate: 0       // bytes/s
    property real txRate: 0

    property var _prevCpu: null
    property var _prevNet: null
    property real _prevT: 0

    // Fixed 4-character rate for the resting island (monospace → constant width):
    // "999B", "9.9K", " 42K", "1.2M", "120M", "1.1G"
    function compact(bps) {
        const units = ["B", "K", "M", "G"]
        let v = Math.max(0, bps), i = 0
        while (v >= 999.5 && i < units.length - 1) { v /= 1024; i++ }
        const n = (i > 0 && v < 9.95) ? v.toFixed(1) : String(Math.round(v))
        return n.padStart(3, " ") + units[i]
    }
    // Fixed 4-character percentage: "  7%", " 42%", "100%"
    function pct(f) { return (String(Math.round(Math.max(0, Math.min(1, f)) * 100)) + "%").padStart(4, " ") }

    function human(bps) {
        if (bps < 1024) return Math.round(bps) + " B/s"
        if (bps < 1048576) return (bps / 1024).toFixed(bps < 10240 ? 1 : 0) + " K/s"
        return (bps / 1048576).toFixed(1) + " M/s"
    }

    Process {
        id: proc
        command: ["cat", "/proc/stat", "/proc/meminfo", "/proc/net/dev"]
        stdout: StdioCollector { onStreamFinished: root.parse(text) }
    }
    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: proc.running = true }

    function parse(t) {
        const lines = t.split("\n")
        const now = Date.now()
        let memTotal = 0, memAvail = 0, rx = 0, tx = 0
        for (const l of lines) {
            if (l.startsWith("cpu ")) {
                const v = l.trim().split(/\s+/).slice(1).map(Number)
                const idle = v[3] + v[4], total = v.reduce((a, b) => a + b, 0)
                if (_prevCpu) {
                    const dt = total - _prevCpu.total
                    cpu = dt > 0 ? Math.max(0, Math.min(1, 1 - (idle - _prevCpu.idle) / dt)) : 0
                }
                _prevCpu = { idle, total }
            } else if (l.startsWith("MemTotal:")) memTotal = parseInt(l.split(/\s+/)[1])
            else if (l.startsWith("MemAvailable:")) memAvail = parseInt(l.split(/\s+/)[1])
            else if (l.indexOf(":") > 0 && /^\s*[a-z0-9]+:\s+\d/.test(l)) {
                const [name, rest] = l.split(":")
                if (name.trim() === "lo") continue
                const f = rest.trim().split(/\s+/).map(Number)
                rx += f[0]; tx += f[8]
            }
        }
        if (memTotal > 0) {
            mem = 1 - memAvail / memTotal
            memTotalGiB = memTotal / 1048576
            memUsedGiB = (memTotal - memAvail) / 1048576
        }
        if (_prevNet && now > _prevT) {
            const s = (now - _prevT) / 1000
            rxRate = Math.max(0, (rx - _prevNet.rx) / s)
            txRate = Math.max(0, (tx - _prevNet.tx) / s)
        }
        _prevNet = { rx, tx }
        _prevT = now
    }
}
