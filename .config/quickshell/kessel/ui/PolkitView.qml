// SPDX-License-Identifier: GPL-3.0-or-later
// Polkit prompt in the island: who's asking, password, Cancel / Authenticate.
import QtQuick
import ".."
import "../services"
import "../components"

View {
    id: root
    implicitWidth: 460
    implicitHeight: col.implicitHeight + 32
    readonly property var flow: Polkit.flow
    onShownChanged: if (shown) pass.focusInput()

    SequentialAnimation {
        id: shake
        NumberAnimation { target: pass; property: "x"; to: 10; duration: 45 }
        NumberAnimation { target: pass; property: "x"; to: -10; duration: 70 }
        NumberAnimation { target: pass; property: "x"; to: 5; duration: 60 }
        NumberAnimation { target: pass; property: "x"; to: 0; duration: 50 }
    }
    Connections {
        target: root.flow
        ignoreUnknownSignals: true
        function onAuthenticationFailed() { pass.text = ""; shake.restart(); pass.focusInput() }
    }

    Column {
        id: col
        x: 20; y: 16
        width: parent.width - 40
        spacing: 10

        Row {
            spacing: 12
            Rectangle {
                width: 36; height: 36; radius: 18
                color: Theme.a(Theme.accent, 0.18)
                Glyph { anchors.centerIn: parent; optical: true; text: Icons.shieldLock; color: Theme.accent; size: Theme.fontUi + 3 }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Label { text: "Authentication required"; font.bold: true }
                Label { text: root.flow?.actionId ?? ""; color: Theme.muted; size: Theme.fontSmall - 1; width: col.width - 50 }
            }
        }
        Text {
            width: parent.width
            text: root.flow?.message ?? ""
            wrapMode: Text.Wrap
            color: Theme.text
            font.family: Theme.font
            font.pointSize: Theme.fontSmall + 0.5
        }
        Item {
            width: parent.width
            height: pass.implicitHeight
            SearchField {
                id: pass
                width: parent.width
                icon: Icons.lock
                placeholder: Polkit.failedOnce ? "Wrong password — try again" : ((root.flow?.inputPrompt ?? "").replace(/:\s*$/, "") || "Password")
                input.echoMode: (root.flow?.responseVisible ?? false) ? TextInput.Normal : TextInput.Password
                onAccepted: { Polkit.submit(text); text = "" }
                input.Keys.onEscapePressed: Polkit.cancel()
            }
        }
        Label {
            visible: text !== ""
            text: root.flow?.supplementaryMessage ?? ""
            color: (root.flow?.supplementaryIsError ?? false) ? Theme.red : Theme.subtext
            size: Theme.fontSmall
            width: parent.width
        }
        Row {
            anchors.right: parent.right
            spacing: 8
            Rectangle {
                width: cl.implicitWidth + 28; height: 32; radius: 16
                color: cma.containsMouse ? Theme.cardHi : Theme.card
                Label { id: cl; anchors.centerIn: parent; text: "Cancel"; size: Theme.fontSmall }
                MouseArea { id: cma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Polkit.cancel() }
            }
            Rectangle {
                width: al.implicitWidth + 28; height: 32; radius: 16
                color: Theme.accent
                Label { id: al; anchors.centerIn: parent; text: "Authenticate"; font.bold: true; size: Theme.fontSmall; color: Theme.base }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { Polkit.submit(pass.text); pass.text = "" } }
            }
        }
    }
}
