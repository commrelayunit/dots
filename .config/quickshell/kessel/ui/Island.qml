// SPDX-License-Identifier: GPL-3.0-or-later
// One black capsule that changes shape. The surface is a fixed transparent
// canvas (resizing a layer surface mid-animation clips); only the pill takes input.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import ".."
import "../services"
import "../components"

PanelWindow {
    id: win

    // Only the island on the focused monitor shows panels / notifications.
    readonly property bool live: !Hyprland.focusedMonitor || Hyprland.focusedMonitor.name === screen?.name
    readonly property string layer: live ? IslandState.layer : "rest"
    readonly property bool panelOpen: layer === "panel"

    visible: IslandState.shown
    anchors.top: true
    margins.top: Theme.islandMargin
    implicitWidth: 1000
    implicitHeight: Math.min(screen ? screen.height - 40 : 700, 700)
    exclusiveZone: Theme.islandHeight + Theme.islandMargin
    color: "transparent"
    mask: Region { item: pill }

    WlrLayershell.namespace: "kessel-island"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: panelOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    IdleInhibitor { window: win; enabled: Session.inhibitIdle }

    // Click outside an open panel closes it.
    // The grab can report "cleared" while the panel is still being created and
    // the surface regains focus, so it is armed only after the opening animation.
    HyprlandFocusGrab {
        id: grab
        windows: [win]
        active: win.panelOpen && armTimer.armed
        onCleared: if (win.panelOpen) IslandState.closePanel()
    }
    Timer {
        id: armTimer
        property bool armed: false
        interval: 400
        onTriggered: armed = true
    }
    onPanelOpenChanged: { armTimer.armed = false; if (panelOpen) armTimer.restart() }

    // The view that currently defines the pill's size.
    readonly property Item current: panelOpen ? panelLoader
        : layer === "notification" ? notifView
        : layer === "osd" ? osdView
        : layer === "summary" ? summaryView
        : restView

    Rectangle {
        id: pill
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.max(Theme.islandHeight * 2, win.current.implicitWidth)
        height: Math.max(Theme.islandHeight, win.current.implicitHeight)
        radius: win.layer === "rest" || win.layer === "osd" ? height / 2 : Theme.radiusPanel
        color: Theme.island
        border.width: 1
        border.color: Theme.a(Theme.text, hover.hovered || win.panelOpen ? 0.12 : 0.06)
        clip: true

        Behavior on width  { NumberAnimation { duration: Theme.animMs; easing.type: Easing.OutBack; easing.overshoot: 0.7 } }
        Behavior on height { NumberAnimation { duration: Theme.animMs; easing.type: Easing.OutBack; easing.overshoot: 0.7 } }
        Behavior on radius { NumberAnimation { duration: Theme.animMs; easing.type: Easing.OutCubic } }

        HoverHandler {
            id: hover
            onHoveredChanged: IslandState.hovered = hovered
        }

        RestView    { id: restView;    shown: win.current === restView }
        SummaryView { id: summaryView; shown: win.current === summaryView }
        OsdView     { id: osdView;     shown: win.current === osdView }
        NotificationView { id: notifView; shown: win.current === notifView }

        Loader {
            id: panelLoader
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            focus: true
            active: win.panelOpen
            opacity: status === Loader.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
            source: {
                switch (IslandState.panel) {
                case "launcher":  return "panels/Launcher.qml"
                case "clipboard": return "panels/ClipboardPanel.qml"
                case "control":   return "panels/ControlCenter.qml"
                case "notifications": return "panels/NotificationsPanel.qml"
                case "notes":     return "panels/NotesPanel.qml"
                case "overview":  return "panels/Overview.qml"
                case "power":     return "panels/PowerPanel.qml"
                case "timer":     return "panels/TimerPanel.qml"
                default:          return ""
                }
            }
            onLoaded: item.forceActiveFocus()
            Keys.onEscapePressed: IslandState.closePanel()
        }
    }
}
