// SPDX-License-Identifier: GPL-3.0-or-later
// Notification server. While Quickshell runs, the island owns
// org.freedesktop.Notifications; when it doesn't, D-Bus activates dunst instead.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import ".."

Singleton {
    id: root

    property bool dnd: false
    property var popup: null
    readonly property var list: server.trackedNotifications.values
    readonly property int count: list.length

    NotificationServer {
        id: server
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: false
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true
            if (!root.dnd || n.urgency === NotificationUrgency.Critical) root.show(n)
        }
    }

    function show(n) {
        popup = n
        const critical = n.urgency === NotificationUrgency.Critical
        popTimer.interval = n.expireTimeout > 0 ? n.expireTimeout : Config.notifTimeoutMs
        if (critical) popTimer.stop(); else popTimer.restart()
    }
    function hidePopup() { popup = null; popTimer.stop() }
    function dismiss(n) {
        if (popup === n) hidePopup()
        n.dismiss()
    }
    function invoke(n, action) {
        action.invoke()
        if (!n.resident) dismiss(n)
    }
    function activate(n) {
        // Clicking the card runs the "default" action if the app offered one.
        const acts = n.actions
        for (let i = 0; i < acts.length; i++)
            if (acts[i].identifier === "default") { invoke(n, acts[i]); return }
        dismiss(n)
    }
    function clearAll() {
        hidePopup()
        const all = list.slice()
        for (let i = 0; i < all.length; i++) all[i].dismiss()
    }

    // Hovering the card holds it; leaving restarts the countdown.
    Timer { id: popTimer; onTriggered: root.popup = null }
    Connections {
        target: IslandState
        function onHoveredChanged() {
            if (root.popup === null || root.popup.urgency === NotificationUrgency.Critical) return
            if (IslandState.hovered) popTimer.stop(); else popTimer.restart()
        }
    }
    // The app may close it (or it may be destroyed) while it is showing.
    onListChanged: if (popup !== null && list.indexOf(popup) < 0) hidePopup()
}
