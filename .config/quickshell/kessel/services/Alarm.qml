// SPDX-License-Identifier: GPL-3.0-or-later
// Alarm when a countdown ends: the island turns red and buzzes until dismissed.
// The freedesktop alarm sound loops (≤ 60 s) if an audio device exists.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool ringing: false
    property string label: ""
    property real since: 0
    readonly property string sound: "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"

    function ring(text) {
        label = text
        since = Date.now()
        ringing = true
        IslandState.shown = true          // even in focus mode
        IslandState.closePanel()
    }
    function dismiss() { ringing = false }
    function snooze(minutes) { ringing = false; Timers.startCountdown(minutes) }

    Process {
        running: root.ringing
        command: ["sh", "-c", 'command -v pw-play >/dev/null && [ -r "$1" ] || exit 0; for i in $(seq 20); do timeout 5 pw-play "$1" 2>/dev/null || exit 0; sleep 0.6; done', "sh", root.sound]
    }
    // give up after 5 minutes so a forgotten alarm doesn't buzz forever
    Timer { running: root.ringing; interval: 300000; onTriggered: root.ringing = false }
}
