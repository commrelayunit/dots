// SPDX-License-Identifier: GPL-3.0-or-later
// MPRIS: picks the playing player (else the first one).
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    property var chosen: null          // set by the player switcher; falls back to auto
    readonly property MprisPlayer player: {
        const ps = Mpris.players.values
        if (chosen && ps.indexOf(chosen) >= 0) return chosen
        for (let i = 0; i < ps.length; i++) if (ps[i].isPlaying) return ps[i]
        return ps.length > 0 ? ps[0] : null
    }
    readonly property bool active: player !== null
    readonly property bool playing: player?.isPlaying ?? false
    readonly property string title: player ? (player.trackTitle || player.identity || "Unknown") : ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string art: player?.trackArtUrl ?? ""
    readonly property string identity: player?.identity ?? ""
    readonly property string album: player?.trackAlbum ?? ""
    readonly property bool shuffle: player?.shuffle ?? false
    readonly property int loop: player?.loopState ?? 0                 // MprisLoopState: None / Track / Playlist
    function toggleShuffle() { if (player?.shuffleSupported) player.shuffle = !player.shuffle }
    function cycleLoop() {
        if (!player?.loopSupported) return
        player.loopState = player.loopState === MprisLoopState.None ? MprisLoopState.Playlist
                         : player.loopState === MprisLoopState.Playlist ? MprisLoopState.Track : MprisLoopState.None
    }
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
