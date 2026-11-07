// SPDX-License-Identifier: GPL-3.0-or-later
// Time service: one SystemClock for the whole shell.
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property date now: clock.date
    readonly property string time: Qt.formatDateTime(clock.date, "HH:mm")
    readonly property string dateShort: Qt.formatDateTime(clock.date, "ddd d MMM")
    readonly property string dateLong: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
