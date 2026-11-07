// SPDX-License-Identifier: GPL-3.0-or-later
// One password character drawn as a Material 3-style shape (like end-4's lock).
// The shape cycles with the character's position, so the field reads as a
// playful row of distinct shapes instead of identical dots.
import QtQuick

Canvas {
    id: root
    property int shapeIndex: 0
    property color color: Style.accent
    readonly property var kinds: ["circle", "clover", "square", "flower", "diamond", "sunny", "star", "heart", "triangle", "pentagon"]
    readonly property string kind: kinds[shapeIndex % kinds.length]

    width: 14; height: 14
    rotation: (shapeIndex * 37) % 30 - 15
    scale: 0
    Component.onCompleted: scale = 1
    Behavior on scale { SpringAnimation { spring: 5; damping: 0.28; epsilon: 0.01 } }
    onColorChanged: requestPaint()

    // r(θ) radial shapes: base * (1 + amp * cos(k θ)) — flowers, clovers, scalloped discs
    function radial(ctx, cx, cy, r, k, amp) {
        ctx.beginPath()
        for (let i = 0; i <= 120; i++) {
            const t = i / 120 * Math.PI * 2
            const rr = r * (1 - amp + amp * Math.cos(k * t))
            const x = cx + rr * Math.cos(t), y = cy + rr * Math.sin(t)
            if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
        }
        ctx.closePath(); ctx.fill()
    }
    // regular polygon with rounded corners (stroke in the same colour rounds them)
    function polygon(ctx, cx, cy, r, n, rot) {
        ctx.beginPath()
        for (let i = 0; i < n; i++) {
            const t = rot + i / n * Math.PI * 2
            const x = cx + r * Math.cos(t), y = cy + r * Math.sin(t)
            if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
        }
        ctx.closePath()
        ctx.lineJoin = "round"; ctx.lineWidth = r * 0.45
        ctx.fill(); ctx.stroke()
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = root.color
        ctx.strokeStyle = root.color
        const w = width, h = height, cx = w / 2, cy = h / 2, r = Math.min(w, h) / 2
        switch (root.kind) {
        case "circle":   ctx.beginPath(); ctx.arc(cx, cy, r * 0.82, 0, Math.PI * 2); ctx.fill(); break
        case "clover":   radial(ctx, cx, cy, r, 4, 0.38); break
        case "flower":   radial(ctx, cx, cy, r, 8, 0.22); break
        case "sunny":    radial(ctx, cx, cy, r, 12, 0.10); break
        case "square":   ctx.beginPath(); ctx.roundedRect(w * 0.12, h * 0.12, w * 0.76, h * 0.76, w * 0.22, h * 0.22); ctx.fill(); break
        case "diamond":  polygon(ctx, cx, cy, r * 0.72, 4, -Math.PI / 2); break
        case "triangle": polygon(ctx, cx, cy * 1.1, r * 0.66, 3, -Math.PI / 2); break
        case "pentagon": polygon(ctx, cx, cy * 1.04, r * 0.7, 5, -Math.PI / 2); break
        case "star": {
            ctx.beginPath()
            for (let i = 0; i < 10; i++) {
                const t = -Math.PI / 2 + i * Math.PI / 5, rr = i % 2 ? r * 0.45 : r * 0.95
                const x = cx + rr * Math.cos(t), y = cy + rr * Math.sin(t)
                if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
            }
            ctx.closePath(); ctx.lineJoin = "round"; ctx.lineWidth = r * 0.25; ctx.fill(); ctx.stroke(); break
        }
        case "heart": {
            ctx.beginPath()
            ctx.moveTo(cx, h * 0.86)
            ctx.bezierCurveTo(w * 0.02, h * 0.55, w * 0.12, h * 0.08, cx, h * 0.3)
            ctx.bezierCurveTo(w * 0.88, h * 0.08, w * 0.98, h * 0.55, cx, h * 0.86)
            ctx.fill(); break
        }
        }
    }
}
