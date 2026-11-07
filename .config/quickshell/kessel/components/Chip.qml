// SPDX-License-Identifier: GPL-3.0-or-later
// Glyph + small label used in the resting island.
import QtQuick
import ".."

Row {
    property string icon: ""
    property string text: ""
    property color tint: Theme.subtext
    property color textColor: Theme.text
    spacing: 5
    Glyph { text: parent.icon; color: parent.tint; size: Theme.fontUi + 1; anchors.verticalCenter: parent.verticalCenter }
    Label { text: parent.text; color: parent.textColor; size: Theme.fontSmall + 0.5; visible: text !== ""; anchors.verticalCenter: parent.verticalCenter }
}
