// SPDX-License-Identifier: GPL-3.0-or-later
// Island "perspectives" for the resting state. Scroll over the island to rotate.
// Music is offered only while a player exists and is entered automatically when
// playback starts (and left again when it stops, if it was entered that way).
pragma Singleton
import QtQuick
import Quickshell
import ".."

Singleton {
    id: root
    readonly property var all: [
        { id: "overview", label: "Overview", icon: Icons.apps },
        { id: "time",     label: "Time",     icon: Icons.calendar },
        { id: "music",    label: "Music",    icon: Icons.music },
        { id: "system",   label: "Metrics",  icon: Icons.cpu },
        { id: "minimal",  label: "Minimal",  icon: Icons.clock }
    ]
    readonly property var available: all.filter(p => p.id !== "music" || Media.active)
    property string current: "overview"
    property bool autoEntered: false
    property bool recentlyScrolled: false
    readonly property var info: all.find(p => p.id === current) ?? all[0]

    function rotate(step) {
        const ids = available.map(p => p.id)
        let i = ids.indexOf(current)
        if (i < 0) i = 0
        current = ids[(i + step + ids.length) % ids.length]
        autoEntered = false
        recentlyScrolled = true
        scrollCalm.restart()
        IslandState.summary = false
    }
    function set(id) { if (available.some(p => p.id === id)) { current = id; autoEntered = false } }
    Timer { id: scrollCalm; interval: 1500; onTriggered: root.recentlyScrolled = false }

    // auto music mode
    Connections {
        target: Media
        function onPlayingChanged() {
            if (Media.playing && root.current === "overview") { root.current = "music"; root.autoEntered = true }
            else if (!Media.playing && root.autoEntered) stopTimer.restart()
        }
        function onActiveChanged() { if (!Media.active && root.current === "music") root.current = "overview" }
    }
    // the island may (re)start while something is already playing
    Timer { interval: 1500; running: true; onTriggered: if (Media.playing && root.current === "overview") { root.current = "music"; root.autoEntered = true } }

    // paused for a while → go back to where we were
    Timer { id: stopTimer; interval: 8000; onTriggered: if (!Media.playing && root.autoEntered) { root.current = "overview"; root.autoEntered = false } }
}
