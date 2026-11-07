// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import ".."

Text {
    property real size: Theme.fontUi + 3
    font.family: Theme.font
    font.pointSize: size
    color: Theme.text
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
