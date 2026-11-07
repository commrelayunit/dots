// SPDX-License-Identifier: GPL-3.0-or-later
// Round profile picture from ~/.face, falling back to the user's initial.
import QtQuick
import ".."
import "../services"

Rectangle {
    id: root
    property real size: 44
    implicitWidth: size
    implicitHeight: size
    radius: size / 2
    color: Theme.a(Theme.accent, 0.25)
    clip: true
    Label {
        anchors.centerIn: parent
        visible: img.status !== Image.Ready
        text: (User.realName || User.name).charAt(0).toUpperCase()
        font.bold: true
        size: root.size * 0.32
        color: Theme.accent
    }
    Image {
        id: img
        anchors.fill: parent
        source: User.hasFace ? "file://" + User.face : ""
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        fillMode: Image.PreserveAspectCrop
        cache: false
        asynchronous: true
    }
}
