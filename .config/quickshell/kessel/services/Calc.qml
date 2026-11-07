// SPDX-License-Identifier: GPL-3.0-or-later
// Launcher calculator. Uses `qalc` (libqalculate, like end-4) when installed:
// units, currencies, functions. Otherwise a tiny built-in parser for
// + - * / % ^ and parentheses. Input is never eval'd.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool qalcAvailable: false
    property string query: ""
    property string result: ""

    Process {
        running: true
        command: ["sh", "-c", "command -v qalc >/dev/null"]
        onExited: code => root.qalcAvailable = code === 0
    }

    // Looks like math: "=…", or digits with at least one operator.
    function looksLikeMath(q) {
        q = (q || "").trim()
        if (q.startsWith("=")) return q.length > 1
        return /\d/.test(q) && /[+\-*/^%()]/.test(q) && /^[\d\s.,+\-*/^%()]+$/.test(q)
    }
    function expr(q) { q = q.trim(); return q.startsWith("=") ? q.slice(1).trim() : q }

    function evaluate(q) {
        query = q
        if (!looksLikeMath(q)) { result = ""; return }
        if (qalcAvailable) { debounce.restart(); return }
        result = builtin(expr(q))
    }
    Timer { id: debounce; interval: 120; onTriggered: { proc.command = ["qalc", "-t", root.expr(root.query)]; proc.running = true } }
    Process {
        id: proc
        stdout: StdioCollector { onStreamFinished: root.result = text.trim().split("\n").pop() || "" }
    }

    // ── fallback: recursive-descent arithmetic ──────────────────────────────
    function builtin(s) {
        let i = 0
        s = s.replace(/,/g, ".").replace(/\s+/g, "")
        function num() {
            const m = s.slice(i).match(/^\d*\.?\d+(e[+-]?\d+)?/i)
            if (!m) throw "number expected"
            i += m[0].length
            return parseFloat(m[0])
        }
        function factor() {
            if (s[i] === "+") { i++; return factor() }
            if (s[i] === "-") { i++; return -factor() }
            let v
            if (s[i] === "(") { i++; v = sum(); if (s[i] !== ")") throw ") expected"; i++ }
            else v = num()
            if (s[i] === "^") { i++; v = Math.pow(v, factor()) }
            return v
        }
        function product() {
            let v = factor()
            while (s[i] === "*" || s[i] === "/" || s[i] === "%") {
                const op = s[i++], r = factor()
                v = op === "*" ? v * r : op === "/" ? v / r : v % r
            }
            return v
        }
        function sum() {
            let v = product()
            while (s[i] === "+" || s[i] === "-") { const op = s[i++]; const r = product(); v = op === "+" ? v + r : v - r }
            return v
        }
        try {
            const v = sum()
            if (i !== s.length || !isFinite(v)) return ""
            return String(Math.round(v * 1e10) / 1e10)
        } catch (e) { return "" }
    }

    function copy(text) { Quickshell.execDetached(["wl-copy", "--", text]) }
}
