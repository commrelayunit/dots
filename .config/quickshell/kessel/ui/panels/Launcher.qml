// SPDX-License-Identifier: GPL-3.0-or-later
// Spotlight-style launcher (SUPER+Space). Fuzzel stays on SUPER+R as the
// Quickshell-independent launcher.
import QtQuick
import Quickshell
import "../.."
import "../../services"
import "../../components"

PanelBase {
    id: root
    title: "Launch"
    icon: Icons.apps
    contentWidth: 520
    contentHeight: search.height + 10 + list.height

    property var results: Apps.query(search.text)

    function launchCurrent() {
        if (list.currentIndex < 0 || list.currentIndex >= results.length) return
        Apps.launch(results[list.currentIndex])
        IslandState.closePanel()
    }

    onActiveFocusChanged: if (activeFocus) search.focusInput()

    SearchField {
        id: search
        width: parent.width
        placeholder: "Search applications"
        onTextChanged: list.currentIndex = 0
        onAccepted: root.launchCurrent()
        onUp: list.decrementCurrentIndex()
        onDown: list.incrementCurrentIndex()
    }

    ListView {
        id: list
        anchors.top: search.bottom
        anchors.topMargin: 10
        width: parent.width
        height: Math.min(8, Math.max(1, count)) * 48
        clip: true
        model: root.results
        currentIndex: 0
        highlightMoveDuration: 120
        boundsBehavior: Flickable.StopAtBounds
        highlight: Rectangle { radius: 12; color: Theme.cardHi }

        delegate: Item {
            id: d
            required property var modelData
            required property int index
            width: list.width
            height: 48
            Image {
                id: appIcon
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 30; height: 30
                sourceSize: Qt.size(60, 60)
                source: Quickshell.iconPath(d.modelData.icon, "application-x-executable")
                asynchronous: true
            }
            Column {
                anchors.left: appIcon.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                Label { text: d.modelData.name; width: parent.width }
                Label { text: d.modelData.comment || d.modelData.genericName || ""; visible: text !== ""; color: Theme.subtext; size: Theme.fontSmall; width: parent.width }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: list.currentIndex = d.index
                onClicked: { list.currentIndex = d.index; root.launchCurrent() }
            }
        }
        Label {
            visible: list.count === 0
            anchors.centerIn: parent
            text: "No matches"
            color: Theme.subtext
        }
    }
}
