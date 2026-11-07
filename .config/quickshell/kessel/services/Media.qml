// SPDX-License-Identifier: GPL-3.0-or-later
// MPRIS: picks the playing player (else the first one).
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property MprisPlayer player: {
        const ps = Mpris.players.values
        for (let i = 0; i < ps.length; i++) if (ps[i].isPlaying) return ps[i]
        return ps.length > 0 ? ps[0] : null
    }
    readonly property bool active: player !== null
    readonly property bool playing: player?.isPlaying ?? false
    readonly property string title: player ? (player.trackTitle || player.identity || "Unknown") : ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string art: player?.trackArtUrl ?? ""
    readonly property string identity: player?.identity ?? ""
    readonly property real length: player?.length ?? 0
    readonly property real position: player?.position ?? 0
    readonly property real progress: length > 0 ? Math.min(1, position / length) : 0

    function toggle() { if (player?.canTogglePlaying) player.togglePlaying() }
    function next() { if (player?.canGoNext) player.next() }
    function prev() { if (player?.canGoPrevious) player.previous() }
    function seekTo(frac) { if (player?.canSeek && length > 0) player.position = frac * length }

    // MPRIS does not push position updates; poll while playing.
    Timer {
        running: root.playing
        interval: 1000
        repeat: true
        onTriggered: root.player?.positionChanged()
    }
}
