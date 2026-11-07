// SPDX-License-Identifier: GPL-3.0-or-later
// cliphist history: list, copy back, delete, image thumbnails.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var entries: []          // [{ id, text, image }]
    readonly property string thumbDir: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/kessel-clip"

    function refresh() { if (!lister.running) lister.running = true }

    Process {
        id: lister
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = []
                for (const line of text.split("\n")) {
                    const tab = line.indexOf("\t")
                    if (tab <= 0) continue
                    const id = line.slice(0, tab)
                    if (!/^\d+$/.test(id)) continue
                    const t = line.slice(tab + 1)
                    out.push({ id: id, text: t, image: /^\[\[ binary data .* (png|jpe?g|webp|bmp|gif)/i.test(t) })
                }
                root.entries = out
            }
        }
    }

    // ids are validated numeric above; they are still passed as arguments, never interpolated.
    function copy(e) {
        Quickshell.execDetached(["sh", "-c", 'cliphist decode "$1" | wl-copy', "sh", e.id])
    }
    function remove(e) {
        Quickshell.execDetached(["sh", "-c", 'cliphist list | awk -F "\t" -v id="$1" \'$1 == id\' | cliphist delete', "sh", e.id])
        entries = entries.filter(x => x.id !== e.id)
    }
    function wipe() { Quickshell.execDetached(["cliphist", "wipe"]); entries = [] }
    function thumbPath(e) { return thumbDir + "/" + e.id + ".png" }
    function thumbCommand(e) {
        return ["sh", "-c", 'mkdir -p "$1" && f="$1/$2.png" && { [ -s "$f" ] || cliphist decode "$2" > "$f"; }', "sh", thumbDir, e.id]
    }
}
