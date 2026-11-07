// SPDX-License-Identifier: GPL-3.0-or-later
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property date now: clock.date
    readonly property string time: Qt.formatDateTime(clock.date, "HH:mm")
    readonly property string dateShort: Qt.formatDateTime(clock.date, "ddd d MMM")
    readonly property string dateLong: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy")

    SystemClock { id: clock; precision: SystemClock.Seconds }

    function hms(sec) {
        sec = Math.max(0, Math.floor(sec))
        const h = Math.floor(sec / 3600), m = Math.floor(sec % 3600 / 60), s = sec % 60
        const mm = (h > 0 && m < 10 ? "0" : "") + m, ss = (s < 10 ? "0" : "") + s
        return h > 0 ? `${h}:${mm}:${ss}` : `${mm}:${ss}`
    }
}
