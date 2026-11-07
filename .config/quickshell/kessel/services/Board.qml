// SPDX-License-Identifier: GPL-3.0-or-later
// Kanban board stored as plain Markdown in ~/Notes/Board.md:
//   ## To do / ## Doing / ## Done   with "- " card lines underneath.
// Readable and editable by hand; external edits are picked up.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property string path: Quickshell.env("HOME") + "/Notes/Board.md"
    readonly property var columns: [
        { id: "todo",  title: "To do" },
        { id: "doing", title: "Doing" },
        { id: "done",  title: "Done" }
    ]
    property var cards: ({ todo: [], doing: [], done: [] })   // arrays of strings
    property bool loaded: false

    FileView {
        id: file
        path: root.path
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: { root.cards = root.parse(text()); root.loaded = true }
        onLoadFailed: { root.loaded = true }
    }

    function parse(md) {
        const out = { todo: [], doing: [], done: [] }
        let col = "todo"
        for (const raw of md.split("\n")) {
            const l = raw.trim()
            const h = l.match(/^#{2,3}\s+(.*)$/)
            if (h) {
                const t = h[1].toLowerCase()
                col = t.startsWith("doing") || t.startsWith("in progress") ? "doing"
                    : t.startsWith("done") ? "done" : "todo"
                continue
            }
            const c = l.match(/^[-*]\s+(?:\[[ xX]\]\s+)?(.+)$/)
            if (c) out[col].push(c[1])
        }
        return out
    }
    function serialize(c) {
        const box = { todo: "[ ] ", doing: "[ ] ", done: "[x] " }
        let s = "# Board\n"
        for (const col of columns) {
            s += "\n## " + col.title + "\n\n"
            for (const t of c[col.id]) s += "- " + box[col.id] + t + "\n"
        }
        return s
    }
    function commit(c) { cards = c; Quickshell.execDetached(["mkdir", "-p", path.substring(0, path.lastIndexOf("/"))]); file.setText(serialize(c)) }
    function clone() { return { todo: cards.todo.slice(), doing: cards.doing.slice(), done: cards.done.slice() } }

    function add(col, text) { text = (text || "").trim(); if (!text) return; const c = clone(); c[col].push(text); commit(c) }
    function remove(col, i) { const c = clone(); c[col].splice(i, 1); commit(c) }
    function rename(col, i, text) { text = (text || "").trim(); if (!text) return remove(col, i); const c = clone(); c[col][i] = text; commit(c) }
    function move(from, i, to, at) {
        if (from === to && (at === undefined || at === i)) return
        const c = clone()
        const [t] = c[from].splice(i, 1)
        if (at === undefined || at < 0 || at > c[to].length) c[to].push(t); else c[to].splice(at, 0, t)
        commit(c)
    }
    function shift(col, i, dir) {
        const ids = columns.map(c => c.id)
        const j = ids.indexOf(col) + dir
        if (j >= 0 && j < ids.length) move(col, i, ids[j])
    }
}
