// SPDX-License-Identifier: GPL-3.0-or-later
// Bluetooth via BlueZ (Quickshell.Bluetooth). Hidden when there is no adapter.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io

Singleton {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false
    readonly property var devices: available
        ? adapter.devices.values.slice().sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || (a.name || "").localeCompare(b.name || ""))
        : []
    readonly property var connected: devices.filter(d => d.connected)

    // Why there's no adapter, for the quick-settings subtitle: BlueZ missing,
    // its service stopped, or really no hardware. Re-checked on refresh().
    property string missingReason: "No adapter"
    function refresh() { if (!available) probe.running = true }
    Process {
        id: probe
        running: !root.available
        command: ["sh", "-c", "command -v bluetoothctl >/dev/null || { echo nobluez; exit; }; systemctl is-active --quiet bluetooth || { echo stopped; exit; }; echo nohw"]
        stdout: StdioCollector {
            onStreamFinished: {
                const r = text.trim()
                root.missingReason = r === "nobluez" ? "Not installed (install.sh --with-laptop)"
                    : r === "stopped" ? "Service off: sudo systemctl enable --now bluetooth"
                    : "No adapter"
            }
        }
    }

    function setEnabled(on) { if (available) adapter.enabled = on }
    function scan(on) { if (available && adapter.enabled) adapter.discovering = on }
    function toggleDevice(d) {
        if (d.connected) d.disconnect()
        else if (d.paired) d.connect()
        else { d.trusted = true; d.pair() }
    }
}
