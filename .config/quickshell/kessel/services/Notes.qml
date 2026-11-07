// SPDX-License-Identifier: GPL-3.0-or-later
// Markdown notes in ~/Notes: list, open, autosave, create, delete (→ ~/Notes/.trash).
// External edits (e.g. in nvim) are picked up when the open note has no unsaved changes.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property string dir: Quickshell.env("HOME") + "/Notes"
    property var files: []                // [{ name, path, mtime }] newest first (excludes Board.md)
    property string current: ""           // path of the open note
    property string text: ""
    property bool dirty: false
    readonly property string currentName: current === "" ? "" : current.substring(current.lastIndexOf("/") + 1).replace(/\.md$/, "")

    function refresh() { if (!lister.running) lister.running = true }
    Process {
        id: lister
        // first run also migrates the old single scratch note
        command: ["sh", "-c", 'mkdir -p "$1" && { [ -s "$HOME/Documents/notes/kessel.md" ] && [ ! -e "$1/Scratch.md" ] && cp "$HOME/Documents/notes/kessel.md" "$1/Scratch.md"; true; } && find "$1" -maxdepth 1 -type f -name "*.md" ! -name "Board.md" -printf "%T@\\t%p\\n" | sort -rn', "sh", root.dir]
        stdout: StdioCollector {
            onStreamFinished: {
                root.files = text.split("\n").filter(l => l.indexOf("\t") > 0).map(l => {
                    const [t, p] = l.split("\t")
                    return { name: p.substring(p.lastIndexOf("/") + 1).replace(/\.md$/, ""), path: p, mtime: parseFloat(t) * 1000 }
                })
                if (root.current === "" && root.files.length > 0) root.open(root.files[0].path)
            }
        }
    }
    Component.onCompleted: refresh()

    FileView {
        id: file
        path: root.current
        watchChanges: true
        printErrors: false
        onFileChanged: if (!root.dirty) reload()
        onLoaded: { root.text = text(); root.dirty = false }
        onLoadFailed: { root.text = ""; root.dirty = false }
    }
    Timer { id: saveTimer; interval: 700; onTriggered: root.save() }

    function open(path) { if (dirty) save(); current = path }
    function edit(t) { if (t === text) return; text = t; dirty = true; saveTimer.restart() }
    function save() {
        if (current === "" || !dirty) return
        file.setText(text)
        dirty = false
        refresh()
    }
    function sanitize(name) {
        return (name || "").trim().replace(/[\/\\:*?"<>|\x00-\x1f]/g, "-").replace(/^\.+/, "").slice(0, 80)
    }
    function create(name) {
        if (dirty) save()
        let base = sanitize(name) || Qt.formatDateTime(new Date(), "yyyy-MM-dd HHmm")
        let path = dir + "/" + base + ".md", n = 2
        while (files.some(f => f.path === path)) path = dir + "/" + base + " " + (n++) + ".md"
        current = path
        text = "# " + base + "\n\n"
        dirty = true
        save()
    }
    function remove(path) {
        if (path === current) { current = ""; text = ""; dirty = false }
        Quickshell.execDetached(["sh", "-c", 'mkdir -p "$1/.trash" && mv -- "$2" "$1/.trash/$(date +%Y%m%d-%H%M%S)-$(basename "$2")"', "sh", dir, path])
        Qt.callLater(refresh)
        trashTimer.restart()
    }
    Timer { id: trashTimer; interval: 300; onTriggered: root.refresh() }
}
