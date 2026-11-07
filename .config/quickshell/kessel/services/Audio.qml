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

    // Per-app streams. Playback = apps making sound; recorders = apps capturing
    // (cava and monitor captures are not "microphone use").
    // Classified by PwNodeType (properties are only filled in once a node is tracked).
    function isType(n, t) { return (n.type & t) === t }
    readonly property var streams: Pipewire.nodes.values.filter(n => n.audio && n.type === PwNodeType.AudioOutStream)
    readonly property var recorders: Pipewire.nodes.values.filter(n => n.type === PwNodeType.AudioInStream
        && !/cava/i.test(n.name ?? "")
        && ((n.properties ?? {})["stream.capture.sink"] ?? "") !== "true")
    readonly property var cameras: Pipewire.nodes.values.filter(n => isType(n, PwNodeType.Video) && isType(n, PwNodeType.Stream))
    function appName(n) { const p = n.properties ?? {}; return p["application.name"] || p["application.process.binary"] || n.description || n.name || "App" }
    function appIcon(n) { const p = n.properties ?? {}; return p["application.icon-name"] || (p["application.process.binary"] ?? "").toLowerCase() || "audio-x-generic" }
    function mediaName(n) { return (n.properties ?? {})["media.name"] ?? "" }
    function setStreamVolume(n, v) { if (n.audio) { n.audio.muted = false; n.audio.volume = clamp(v) } }
    function toggleStreamMute(n) { if (n.audio) n.audio.muted = !n.audio.muted }
    PwObjectTracker { objects: root.streams }

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
