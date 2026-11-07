// SPDX-License-Identifier: GPL-3.0-or-later
// One password character drawn as a Material 3 "expressive" shape (cookie,
// clover, sunny, burst, gem…), like end-4's lock screen. Written from scratch:
// shapes are polygons/stars whose corners are rounded with true circular arcs
// (the M3 RoundedPolygon idea), sampled to a point list and drawn by the
// antialiased curve renderer — crisp at any scale, unlike a Canvas.
// Shared: the SDDM theme gets a copy of this file at install (scripts/sddm-theme.sh).
import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property color color: "#8aadf4"   // set by the user (lock: Style.accent, SDDM: root.accent)
    property real size: 18
    // Each character picks its own shape when it appears (stable afterwards).
    readonly property int pick: Math.floor(Math.random() * kinds.length)
    property string forced: ""        // fixed shape (previews / tests)
    readonly property string kind: forced !== "" ? forced : kinds[pick]
    readonly property var kinds: ["circle", "square", "cookie4", "cookie6", "cookie9", "cookie12",
        "clover4", "clover8", "sunny", "verySunny", "softBurst", "burst", "flower",
        "triangle", "pentagon", "gem", "diamond", "pill", "puffy", "heart"]

    width: size; height: size

    // pop in: grow with a little overshoot while untwisting into a random tilt
    scale: 0
    rotation: -60
    readonly property real tilt: (Math.random() * 30) - 15
    Component.onCompleted: { scale = 1; rotation = tilt }
    Behavior on scale { SpringAnimation { spring: 4.5; damping: 0.3; epsilon: 0.005 } }
    Behavior on rotation { SpringAnimation { spring: 3.5; damping: 0.35; epsilon: 0.05 } }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: root.color
            strokeWidth: -1
            PathPolyline { path: root.points }
        }
    }

    readonly property var points: geo.build(kind, size)

    // ── geometry ────────────────────────────────────────────────────────────
    QtObject {
        id: geo
        // vertices of a regular polygon / star on the unit circle
        function poly(n, rot) {
            const v = []
            for (let i = 0; i < n; i++) { const t = rot + i / n * 2 * Math.PI; v.push([Math.cos(t), Math.sin(t)]) }
            return v
        }
        function star(n, inner, rot) {
            const v = []
            for (let i = 0; i < 2 * n; i++) {
                const t = rot + i / (2 * n) * 2 * Math.PI, r = i % 2 ? inner : 1
                v.push([r * Math.cos(t), r * Math.sin(t)])
            }
            return v
        }
        // Round every corner i with radius r[i] (unit-circle units): the arc is
        // tangent to both edges, and shrinks if the edges are too short for it.
        function rounded(v, r) {
            const out = [], n = v.length
            for (let i = 0; i < n; i++) {
                const p0 = v[(i + n - 1) % n], p1 = v[i], p2 = v[(i + 1) % n]
                const a = [p0[0] - p1[0], p0[1] - p1[1]], b = [p2[0] - p1[0], p2[1] - p1[1]]
                const la = Math.hypot(a[0], a[1]), lb = Math.hypot(b[0], b[1])
                const u1 = [a[0] / la, a[1] / la], u2 = [b[0] / lb, b[1] / lb]
                const theta = Math.acos(Math.max(-1, Math.min(1, u1[0] * u2[0] + u1[1] * u2[1])))
                let rad = Array.isArray(r) ? r[i] : r
                let d = rad / Math.tan(theta / 2)
                const dmax = 0.5 * Math.min(la, lb)
                if (d > dmax) { d = dmax; rad = d * Math.tan(theta / 2) }
                if (rad < 1e-4) { out.push(p1); continue }
                const t1 = [p1[0] + u1[0] * d, p1[1] + u1[1] * d], t2 = [p1[0] + u2[0] * d, p1[1] + u2[1] * d]
                const bis = [u1[0] + u2[0], u1[1] + u2[1]], lbis = Math.hypot(bis[0], bis[1])
                const h = rad / Math.sin(theta / 2)
                const c = [p1[0] + bis[0] / lbis * h, p1[1] + bis[1] / lbis * h]
                let a1 = Math.atan2(t1[1] - c[1], t1[0] - c[0]), a2 = Math.atan2(t2[1] - c[1], t2[0] - c[0])
                let sweep = a2 - a1
                while (sweep > Math.PI) sweep -= 2 * Math.PI
                while (sweep < -Math.PI) sweep += 2 * Math.PI
                const steps = Math.max(3, Math.ceil(Math.abs(sweep) / (Math.PI / 12)))
                for (let s = 0; s <= steps; s++) {
                    const t = a1 + sweep * s / steps
                    out.push([c[0] + rad * Math.cos(t), c[1] + rad * Math.sin(t)])
                }
            }
            return out
        }
        // alternate outer/inner radii for stars
        function alt(n, ro, ri) { const r = []; for (let i = 0; i < 2 * n; i++) r.push(i % 2 ? ri : ro); return r }
        function circle() { const v = []; for (let i = 0; i < 64; i++) { const t = i / 64 * 2 * Math.PI; v.push([Math.cos(t), Math.sin(t)]) } return v }
        function scaleXY(v, sx, sy) { return v.map(p => [p[0] * sx, p[1] * sy]) }

        function unit(kind) {
            const up = -Math.PI / 2
            switch (kind) {
            case "circle":    return circle()
            case "square":    return rounded(poly(4, Math.PI / 4), 0.32)
            case "cookie4":   return rounded(star(4, 0.62, Math.PI / 4), alt(4, 0.5, 0.42))
            case "cookie6":   return rounded(star(6, 0.80, up), alt(6, 0.38, 0.35))
            case "cookie9":   return rounded(star(9, 0.86, up), alt(9, 0.26, 0.24))
            case "cookie12":  return rounded(star(12, 0.89, up), alt(12, 0.2, 0.18))
            case "clover4":   return rounded(star(4, 0.38, Math.PI / 4), alt(4, 0.62, 0.08))
            case "clover8":   return rounded(star(8, 0.70, up), alt(8, 0.3, 0.06))
            case "sunny":     return rounded(star(8, 0.80, up), alt(8, 0.14, 0.14))
            case "verySunny": return rounded(star(8, 0.64, up), alt(8, 0.12, 0.12))
            case "softBurst": return rounded(star(10, 0.70, up), alt(10, 0.12, 0.08))
            case "burst":     return rounded(star(12, 0.74, up), alt(12, 0.04, 0.04))
            case "flower":    return rounded(star(8, 0.58, up), alt(8, 0.42, 0.04))
            case "triangle":  return rounded(poly(3, up), 0.26)
            case "pentagon":  return rounded(poly(5, up), 0.22)
            case "gem":       return rounded(scaleXY(poly(6, 0), 1, 0.86), 0.24)
            case "diamond":   return rounded(scaleXY(poly(4, up), 0.82, 1.08), 0.22)
            case "pill":      return rounded(scaleXY(poly(4, Math.PI / 4), 1.0, 0.62), 0.6)
            case "puffy":     return rounded(scaleXY(star(6, 0.84, 0), 1.08, 0.9), alt(6, 0.5, 0.2))
            case "heart": {
                // two lobes + a rounded tip, built from a 5-point outline
                const v = [[0, 0.95], [-0.95, -0.05], [-0.5, -0.82], [0, -0.42], [0.5, -0.82], [0.95, -0.05]]
                return rounded(v, [0.18, 0.5, 0.42, 0.12, 0.42, 0.5])
            }
            }
            return circle()
        }
        // fit the unit outline into a size×size box (keeping aspect), centred
        function build(kind, size) {
            const v = unit(kind)
            let x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9
            for (const p of v) { x0 = Math.min(x0, p[0]); y0 = Math.min(y0, p[1]); x1 = Math.max(x1, p[0]); y1 = Math.max(y1, p[1]) }
            const s = size / Math.max(x1 - x0, y1 - y0)
            const ox = (size - (x1 - x0) * s) / 2, oy = (size - (y1 - y0) * s) / 2
            const pts = v.map(p => Qt.point(ox + (p[0] - x0) * s, oy + (p[1] - y0) * s))
            pts.push(pts[0])
            return pts
        }
    }
}
