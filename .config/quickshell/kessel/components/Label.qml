// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import ".."

Text {
    property real size: Theme.fontUi
    font.family: Theme.font
    font.pointSize: size
    color: Theme.text
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
}
