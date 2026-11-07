// SPDX-License-Identifier: GPL-3.0-or-later
// Bluetooth via BlueZ (Quickshell.Bluetooth). Hidden when there is no adapter.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

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

    function setEnabled(on) { if (available) adapter.enabled = on }
    function scan(on) { if (available && adapter.enabled) adapter.discovering = on }
    function toggleDevice(d) {
        if (d.connected) d.disconnect()
        else if (d.paired) d.connect()
        else { d.trusted = true; d.pair() }
    }
}
