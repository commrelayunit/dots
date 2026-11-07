// SPDX-License-Identifier: GPL-3.0-or-later
// A single persistent scratch note (Markdown), saved as you type.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property string path: Quickshell.env("HOME") + "/Documents/notes/kessel.md"
    property string text: ""
    property bool loaded: false

    FileView {
        id: file
        path: root.path
        printErrors: false
        onLoaded: { root.text = text(); root.loaded = true }
        onLoadFailed: root.loaded = true
    }
    Timer { id: saveTimer; interval: 600; onTriggered: root.flush() }

    function update(t) { text = t; saveTimer.restart() }
    function flush() {
        Quickshell.execDetached(["mkdir", "-p", path.substring(0, path.lastIndexOf("/"))])
        file.setText(text)
    }
}
