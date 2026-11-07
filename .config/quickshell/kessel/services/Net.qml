// SPDX-License-Identifier: GPL-3.0-or-later
// Network state via NetworkManager (Quickshell.Networking). Works wired-only (VM)
// and with Wi-Fi (laptop). Password entry uses connectWithPsk.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking
import ".."

Singleton {
    id: root

    readonly property bool available: Networking.backend === NetworkBackendType.NetworkManager
    readonly property var devices: Networking.devices.values
    readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: devices.find(d => d.type === DeviceType.Wired) ?? null
    readonly property bool hasWifi: wifiDevice !== null
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wiredConnected: wiredDevice?.connected ?? false

    readonly property var networks: hasWifi
        ? wifiDevice.networks.values.slice().sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))
        : []
    readonly property var activeWifi: networks.find(n => n.connected) ?? null

    readonly property bool online: wiredConnected || activeWifi !== null
    readonly property string label: activeWifi ? activeWifi.name
        : wiredConnected ? "Wired" : hasWifi && wifiEnabled ? "Not connected" : "Offline"
    readonly property string icon: activeWifi ? wifiIcon(activeWifi.signalStrength)
        : wiredConnected ? Icons.ethernet : hasWifi && wifiEnabled ? Icons.wifiOff : Icons.netOff

    function wifiIcon(s) {
        return s > 0.75 ? Icons.wifi4 : s > 0.5 ? Icons.wifi3 : s > 0.25 ? Icons.wifi2 : Icons.wifi1
    }
    function setWifi(on) { Networking.wifiEnabled = on }
    function scan(on) { if (hasWifi) wifiDevice.scannerEnabled = on }
    function connect(n, psk) {
        if (psk !== undefined && psk !== "") n.connectWithPsk(psk)
        else n.connect()
    }
    function disconnect(n) { n.disconnect() }
}
