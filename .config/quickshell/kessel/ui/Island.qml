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
    readonly property bool panelOpen: layer === "panel" && !IslandState.quitting

    visible: IslandState.shown
    anchors.top: true
    margins.top: Theme.islandMargin
    implicitWidth: 1100           // pill (≤ ~800) + the two side buttons
    // Keep the surface a small strip while resting (the compositor blurs behind the
    // whole surface every frame — expensive without a GPU). Grow at once when
    // something tall opens; shrink only after the closing spring has settled.
    readonly property real tallHeight: Math.min(screen ? screen.height - 40 : 700, 700)
    readonly property bool needsTall: layer === "panel" || layer === "notification" || layer === "summary" || layer === "alarm"
    property bool tall: false
    onNeedsTallChanged: { if (needsTall) { shrinkTimer.stop(); tall = true } else shrinkTimer.restart() }
    Timer { id: shrinkTimer; interval: 900; onTriggered: win.tall = win.needsTall }
    implicitHeight: tall ? tallHeight : Theme.islandHeight + 44   // room for the perspective tag
    exclusiveZone: Theme.islandHeight + Theme.islandMargin
    color: "transparent"
    mask: Region {
        item: pill
        Region { item: gearBtn }
        Region { item: bellBtn }
    }

    WlrLayershell.namespace: "kessel-island"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: panelOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    IdleInhibitor { window: win; enabled: Session.inhibitIdle }

    // takes keyboard focus away from text fields before a graceful quit
    Item { id: focusSink; focus: false }
    Connections {
        target: IslandState
        function onQuittingChanged() { if (IslandState.quitting) focusSink.forceActiveFocus() }
    }

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
    readonly property Item current: layer === "alarm" ? alarmView
        : panelOpen ? panelLoader
        : layer === "notification" ? notifView
        : layer === "osd" ? osdView
        : layer === "summary" ? summaryView
        : restView

    // Floating side buttons: gear → quick settings, bell → notifications.
    // They ride the pill's edges, so they glide outward as it morphs.
    SideButton {
        id: gearBtn
        y: 0
        x: pill.x - width - 8
        icon: Icons.settings
        active: IslandState.panel === "control"
        onClicked: IslandState.openPanel("control")
    }
    SideButton {
        id: bellBtn
        y: 0
        x: pill.x + pill.width + 8
        icon: Notifs.dnd ? Icons.bellOff : Icons.bell
        tint: Notifs.dnd ? Theme.red : Theme.accent
        active: IslandState.panel === "notifications" || Notifs.dnd
        badge: Notifs.dnd ? 0 : Notifs.count
        onClicked: IslandState.openPanel("notifications")
    }

    // Perspective name, shown briefly *below* the island while scrolling through
    // perspectives (it never takes over the pill, so the morph goes straight on).
    Rectangle {
        id: perspTag
        readonly property bool on: Perspectives.recentlyScrolled && win.layer === "rest"
        anchors.horizontalCenter: pill.horizontalCenter
        y: pill.height + (on ? 8 : 0)
        width: tagRow.implicitWidth + 20
        height: 24
        radius: 12
        color: Theme.island
        border.width: 1
        border.color: Theme.a(Theme.text, 0.08)
        opacity: on ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 180 } }
        Behavior on y { SpringAnimation { spring: Theme.springStiffness; damping: 0.4; epsilon: 0.25 } }
        Row {
            id: tagRow
            anchors.centerIn: parent
            spacing: 6
            Glyph { text: Perspectives.info.icon; size: Theme.fontSmall; color: Theme.accent; anchors.verticalCenter: parent.verticalCenter }
            Label { text: Perspectives.info.label; size: Theme.fontSmall; anchors.verticalCenter: parent.verticalCenter }
            Row {
                spacing: 3
                anchors.verticalCenter: parent.verticalCenter
                Repeater {
                    model: Perspectives.available
                    Rectangle {
                        required property var modelData
                        width: 5; height: 5; radius: 2.5
                        color: modelData.id === Perspectives.current ? Theme.accent : Theme.a(Theme.text, 0.25)
                    }
                }
            }
        }
    }

    Rectangle {
        id: pill
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.max(Theme.islandHeight * 2, win.current.implicitWidth)
        height: Math.max(Theme.islandHeight, win.current.implicitHeight)
        radius: win.layer === "rest" || win.layer === "osd" ? height / 2 : Theme.radiusPanel
        color: Theme.island
        border.width: win.layer === "alarm" ? 2 : 1
        border.color: win.layer === "alarm" ? Theme.a(Theme.red, alarmPulse.v) : Theme.a(Theme.text, hover.hovered || win.panelOpen ? 0.12 : 0.06)
        Item {
            id: alarmPulse
            visible: false
            property real v: 1
            SequentialAnimation on v {
                running: win.layer === "alarm"
                loops: Animation.Infinite
                NumberAnimation { to: 0.35; duration: 450; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1; duration: 450; easing.type: Easing.InOutSine }
            }
        }
        // buzz: a short horizontal shake every ~1.2 s while the alarm rings
        transform: Translate { id: buzz; x: 0 }
        SequentialAnimation {
            running: win.layer === "alarm"
            loops: Animation.Infinite
            onStopped: buzz.x = 0
            NumberAnimation { target: buzz; property: "x"; to: -7; duration: 45 }
            NumberAnimation { target: buzz; property: "x"; to: 7; duration: 70 }
            NumberAnimation { target: buzz; property: "x"; to: -5; duration: 60 }
            NumberAnimation { target: buzz; property: "x"; to: 5; duration: 60 }
            NumberAnimation { target: buzz; property: "x"; to: 0; duration: 45 }
            PauseAnimation { duration: 950 }
        }
        clip: true
        onWidthChanged: IslandState.pillWidth = width

        Behavior on width  { SpringAnimation { spring: Theme.springStiffness; damping: Theme.springDamping; mass: Theme.springMass; epsilon: 0.25 } }
        Behavior on height { SpringAnimation { spring: Theme.springStiffness; damping: Theme.springDamping; mass: Theme.springMass; epsilon: 0.25 } }
        Behavior on radius { SpringAnimation { spring: Theme.springStiffness; damping: 0.5; mass: Theme.springMass; epsilon: 0.25 } }

        HoverHandler {
            id: hover
            onHoveredChanged: IslandState.hovered = hovered
        }

        RestView    { id: restView;    shown: win.current === restView }
        SummaryView { id: summaryView; shown: win.current === summaryView; minWidth: restView.implicitWidth }
        OsdView     { id: osdView;     shown: win.current === osdView }
        AlarmView { id: alarmView; shown: win.current === alarmView }
        NotificationView { id: notifView; shown: win.current === notifView; minWidth: restView.implicitWidth }

        Loader {
            id: panelLoader
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            focus: true
            active: win.panelOpen
            opacity: status === Loader.Ready ? 1 : 0
            scale: status === Loader.Ready ? 1 : 0.94
            transformOrigin: Item.Top
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs; easing.type: Easing.OutCubic } }
            Behavior on scale { SpringAnimation { spring: Theme.springStiffness * 1.2; damping: 0.45; epsilon: 0.002 } }
            source: {
                switch (IslandState.panel) {
                case "launcher":  return "panels/Launcher.qml"
                case "clipboard": return "panels/ClipboardPanel.qml"
                case "control":   return "panels/ControlCenter.qml"
                case "notifications": return "panels/NotificationsPanel.qml"
                case "notes":     return "panels/NotesPanel.qml"
                case "board":     return "panels/NotesPanel.qml"
                case "media":     return "panels/MediaPanel.qml"
                case "mixer":     return "panels/MixerPanel.qml"
                case "overview":  return "panels/Overview.qml"
                case "power":     return "panels/PowerPanel.qml"
                case "timer":     return "panels/TimerPanel.qml"
                case "wallpaper": return "panels/WallpaperPanel.qml"
                default:          return ""
                }
            }
            onLoaded: item.forceActiveFocus()
            Keys.onEscapePressed: IslandState.closePanel()
        }
    }
}
