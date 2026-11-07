// SPDX-License-Identifier: GPL-3.0-or-later
// Material 3 "expressive" progress: the played part is a sine wave (animated
// while playing, flattening when paused), the rest a flat track, with a small
// rounded stop at the end. Click/drag to seek when `interactive`.
import QtQuick
import ".."

Item {
    id: root
    property real value: 0              // 0..1
    property bool playing: false
    property bool interactive: false
    property color fill: Theme.accent
    property color track: Theme.a(Theme.text, 0.18)
    property real thickness: 4
    property real amplitude: 3
    property real wavelength: 24
    signal moved(real v)

    implicitWidth: 200
    implicitHeight: Math.max(16, amplitude * 2 + thickness + 4)

    // wave height eases in/out with play state; phase scrolls while playing
    property real amp: playing ? amplitude : 0
    Behavior on amp { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
    property real phase: 0
    NumberAnimation on phase {
        running: root.playing && root.visible
        from: 0; to: Math.PI * 2
        duration: 1200
        loops: Animation.Infinite
    }
    onAmpChanged: canvas.requestPaint()
    onPhaseChanged: canvas.requestPaint()
    onValueChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onFillChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const w = width, mid = height / 2
            const v = Math.max(0, Math.min(1, root.value))
            const end = w * v
            const gap = 6
            ctx.lineCap = "round"
            ctx.lineWidth = root.thickness
            // remaining track
            if (end + gap < w - root.thickness / 2) {
                ctx.strokeStyle = root.track
                ctx.beginPath()
                ctx.moveTo(Math.min(w, end + gap), mid)
                ctx.lineTo(w - root.thickness / 2, mid)
                ctx.stroke()
            }
            // played wave
            if (end > root.thickness / 2) {
                ctx.strokeStyle = root.fill
                ctx.beginPath()
                const k = Math.PI * 2 / root.wavelength
                for (let x = root.thickness / 2; x <= end; x += 1.5) {
                    // taper the wave near the start so it grows out of a point
                    const taper = Math.min(1, x / root.wavelength)
                    const y = mid + root.amp * taper * Math.sin(x * k - root.phase)
                    if (x === root.thickness / 2) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                }
                ctx.stroke()
            }
            // stop indicator at the end of the track
            ctx.fillStyle = root.fill
            ctx.beginPath()
            ctx.arc(w - root.thickness / 2, mid, root.thickness / 2, 0, Math.PI * 2)
            ctx.fill()
        }
    }

    MouseArea {
        enabled: root.interactive
        anchors.fill: parent
        anchors.margins: -6
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        function emitAt(x) { root.moved(Math.max(0, Math.min(1, (x - 6) / root.width))) }
        onPressed: e => emitAt(e.x)
        onPositionChanged: e => { if (pressed) emitAt(e.x) }
    }
}
