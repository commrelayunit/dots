// SPDX-License-Identifier: GPL-3.0-or-later
// PipeWire: output + microphone volume/mute, device switching, volume OSD.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import ".."

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool ready: sink !== null && sink.audio !== null
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property string sinkName: label(sink, "No output")

    readonly property bool micReady: source !== null && source.audio !== null
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? false
    readonly property string sourceName: label(source, "No microphone")

    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    // Sources, without monitor ports of outputs.
    readonly property var sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio
                                                                   && !(n.name || "").endsWith(".monitor"))

    readonly property string icon: muted || volume <= 0.001 ? Icons.volOff
        : volume < 0.34 ? Icons.volLow : volume < 0.67 ? Icons.volMid : Icons.volHigh
    readonly property string micIcon: micMuted ? Icons.micOff : Icons.mic

    function label(n, fallback) { return n ? (n.nickname || n.description || n.name) : fallback }

    PwObjectTracker { objects: [root.sink, root.source] }

    property bool armed: false
    Timer { interval: 1500; running: true; onTriggered: root.armed = true }

    Connections {
        target: root.sink?.audio ?? null
        ignoreUnknownSignals: true
        function onVolumeChanged() { root.osd() }
        function onMutedChanged() { root.osd() }
    }
    Connections {
        target: root.source?.audio ?? null
        ignoreUnknownSignals: true
        function onMutedChanged() {
            if (root.armed) IslandState.showOsd(root.micIcon, root.micMuted ? "Mic muted" : "Mic on", root.micMuted ? 0 : root.micVolume)
        }
    }

    function osd() {
        if (!armed) return
        IslandState.showOsd(icon, muted ? "Muted" : Math.round(volume * 100) + "%", muted ? 0 : volume)
    }
    function setVolume(v) { if (ready) { sink.audio.muted = false; sink.audio.volume = clamp(v) } }
    function toggleMute() { if (ready) sink.audio.muted = !sink.audio.muted }
    function setMicVolume(v) { if (micReady) { source.audio.muted = false; source.audio.volume = clamp(v) } }
    function toggleMicMute() { if (micReady) source.audio.muted = !source.audio.muted }
    function setSink(n) { Pipewire.preferredDefaultAudioSink = n }
    function setSource(n) { Pipewire.preferredDefaultAudioSource = n }
    function clamp(v) { return Math.max(0, Math.min(1, v)) }
}
