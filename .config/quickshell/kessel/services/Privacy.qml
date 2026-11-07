// SPDX-License-Identifier: GPL-3.0-or-later
// Privacy indicators: microphone, camera and screen sharing in use.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root
    readonly property bool mic: Audio.recorders.length > 0
    readonly property string micApps: Audio.recorders.map(n => Audio.appName(n)).join(", ")
    property bool v4l2Open: false
    readonly property bool camera: Audio.cameras.length > 0 || v4l2Open
    property int screencasts: 0
    readonly property bool screen: screencasts > 0
    readonly property bool any: mic || camera || screen

    // cameras opened directly (not via PipeWire): any of our processes holding /dev/video*
    Process {
        id: camProbe
        command: ["sh", "-c", 'for f in /proc/[0-9]*/fd/*; do case "$(readlink "$f" 2>/dev/null)" in /dev/video*) echo yes; exit 0;; esac; done; echo no']
        stdout: StdioCollector { onStreamFinished: root.v4l2Open = text.trim() === "yes" }
    }
    Timer { interval: 4000; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!camProbe.running) camProbe.running = true }

    // Hyprland: "screencast>>STATE,OWNER" (1 = started, 0 = stopped)
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name !== "screencast") return
            const started = (event.data || "").split(",")[0] === "1"
            root.screencasts = Math.max(0, root.screencasts + (started ? 1 : -1))
        }
    }
}
