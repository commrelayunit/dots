// SPDX-License-Identifier: GPL-3.0-or-later
// Countdown timer + stopwatch.
pragma Singleton
import QtQuick
import Quickshell
import ".."

Singleton {
    id: root
    // countdown
    property real cdEnd: 0
    property int cdTotal: 0
    property int cdPausedLeft: 0
    readonly property bool cdRunning: cdEnd > 0
    readonly property bool cdActive: cdRunning || cdPausedLeft > 0
    readonly property int cdLeft: cdRunning ? Math.max(0, Math.ceil((cdEnd - Time.now.getTime()) / 1000)) : cdPausedLeft

    // stopwatch
    property real swStart: 0
    property int swAccum: 0              // ms
    readonly property bool swRunning: swStart > 0
    readonly property int swMs: swAccum + (swRunning ? tick.now - swStart : 0)

    function startCountdown(minutes) { cdTotal = minutes * 60; cdPausedLeft = 0; cdEnd = Date.now() + cdTotal * 1000 }
    function pauseCountdown() { if (cdRunning) { cdPausedLeft = cdLeft; cdEnd = 0 } else if (cdPausedLeft > 0) { cdEnd = Date.now() + cdPausedLeft * 1000; cdPausedLeft = 0 } }
    function cancelCountdown() { cdEnd = 0; cdPausedLeft = 0; cdTotal = 0 }
    function swToggle() { if (swRunning) { swAccum += Date.now() - swStart; swStart = 0 } else swStart = Date.now() }
    function swReset() { swStart = 0; swAccum = 0 }

    onCdLeftChanged: {
        if (cdRunning && cdLeft === 0) {
            cdEnd = 0
            Quickshell.execDetached(["notify-send", "-u", "critical", "-a", "Timer", "Time's up", Time.hms(cdTotal) + " timer finished"])
        }
    }
    Timer { id: tick; property real now: Date.now(); interval: 100; repeat: true; running: root.swRunning; onTriggered: now = Date.now() }
}
