// SPDX-License-Identifier: GPL-3.0-or-later
// Scratch notes (SUPER+G). Saved automatically to ~/Documents/notes/kessel.md.
import QtQuick
import "../.."
import "../../services"
import "../../components"

PanelBase {
    id: root
    title: "Notes"
    icon: Icons.notes
    contentWidth: 560
    contentHeight: 400

    headerExtra: Label { text: "~/Documents/notes/kessel.md"; color: Theme.muted; size: Theme.fontSmall - 0.5; anchors.verticalCenter: parent.verticalCenter }

    onActiveFocusChanged: if (activeFocus) edit.forceActiveFocus()

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusCard
        color: Theme.card
        Flickable {
            id: flick
            anchors.fill: parent
            anchors.margins: 14
            contentHeight: edit.contentHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            function ensureVisible(r) {
                if (contentY >= r.y) contentY = r.y
                else if (contentY + height <= r.y + r.height) contentY = r.y + r.height - height
            }
            TextEdit {
                id: edit
                width: flick.width
                text: Notes.text
                wrapMode: TextEdit.Wrap
                color: Theme.text
                selectionColor: Theme.a(Theme.accent, 0.4)
                font.family: Theme.font
                font.pointSize: Theme.fontMono - 1
                focus: true
                onTextChanged: if (Notes.loaded && text !== Notes.text) Notes.update(text)
                onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                Keys.onEscapePressed: { Notes.flush(); IslandState.closePanel() }
                Text {
                    visible: edit.text === ""
                    text: "Write something…"
                    color: Theme.muted
                    font: edit.font
                }
            }
        }
    }
}
