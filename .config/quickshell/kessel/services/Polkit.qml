// SPDX-License-Identifier: GPL-3.0-or-later
// Polkit authentication agent: admin password prompts appear in the island,
// themed. Only one agent can register per session — island.sh starts
// polkit-gnome instead whenever the island isn't the registered agent.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Singleton {
    id: root
    readonly property bool registered: agent.isRegistered
    readonly property bool active: agent.isActive && agent.flow !== null
    readonly property var flow: agent.flow
    property bool failedOnce: false

    PolkitAgent {
        id: agent
        onAuthenticationRequestStarted: {
            root.failedOnce = false
            IslandState.shown = true          // even in focus mode
            IslandState.closePanel()
        }
    }
    Connections {
        target: root.flow
        ignoreUnknownSignals: true
        function onAuthenticationFailed() { root.failedOnce = true }
    }
    function submit(text) { if (flow) flow.submit(text) }
    function cancel() { if (flow) flow.cancelAuthenticationRequest() }
}
