// SPDX-License-Identifier: GPL-3.0-or-later
// Month grid (Monday first) with month navigation; today highlighted.
import QtQuick
import ".."
import "../services"

Column {
    id: root
    property int offset: 0
    readonly property date month: { const d = new Date(Time.now.getFullYear(), Time.now.getMonth() + offset, 1); return d }
    readonly property int lead: (month.getDay() + 6) % 7
    readonly property int days: new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate()
    spacing: 6
    width: 7 * 40
    readonly property real cell: Math.floor(width / 7)

    Row {
        width: parent.width
        IconButton { icon: Icons.chevronL; size: 26; onClicked: root.offset-- }
        Label {
            width: parent.width - 52
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(root.month, "MMMM yyyy")
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            MouseArea { anchors.fill: parent; onClicked: root.offset = 0 }
        }
        IconButton { icon: Icons.chevronR; size: 26; onClicked: root.offset++ }
    }
    Grid {
        columns: 7
        anchors.horizontalCenter: parent.horizontalCenter
        Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
            Label { required property string modelData; width: root.cell; height: 22; text: modelData; horizontalAlignment: Text.AlignHCenter; color: Theme.subtext; size: Theme.fontSmall - 0.5 }
        }
        Repeater {
            model: 42
            Item {
                required property int index
                readonly property int day: index - root.lead + 1
                readonly property bool inMonth: day >= 1 && day <= root.days
                readonly property bool today: inMonth && root.offset === 0 && day === Time.now.getDate()
                width: root.cell; height: 30
                visible: index < Math.ceil((root.lead + root.days) / 7) * 7
                Rectangle { anchors.centerIn: parent; width: 28; height: 28; radius: 14; color: Theme.accent; visible: parent.today }
                Label {
                    anchors.centerIn: parent
                    text: parent.inMonth ? parent.day : ""
                    color: parent.today ? Theme.base : Theme.text
                    font.bold: parent.today
                    size: Theme.fontSmall
                }
            }
        }
    }
}
