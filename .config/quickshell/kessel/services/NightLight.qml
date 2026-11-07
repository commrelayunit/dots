// SPDX-License-Identifier: GPL-3.0-or-later
// Night light via hyprsunset. Automatic from local sunset to sunrise (times
// from Open-Meteo for the weather location; 20:00–07:00 if unknown). The
// quick-settings tile overrides it until the next sunrise/sunset.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Singleton {
    id: root
    property bool available: false
    readonly property int temperature: Config.nightTemperature
    property var override: null              // null = automatic; true/false = manual until next boundary
    property bool autoState: false
    readonly property bool active: override !== null ? override : autoState
    readonly property bool manual: override !== null

    Process {
        running: true
        command: ["sh", "-c", "command -v hyprsunset >/dev/null"]
        onExited: code => { root.available = code === 0; root.evaluate() }
    }

    function isNight(now) {
        const sr = Weather.sunrise, ss = Weather.sunset          // Date objects for today, or null
        if (sr && ss) return now < sr || now >= ss
        const h = now.getHours()
        return h >= 20 || h < 7
    }
    function evaluate() {
        const night = isNight(new Date())
        if (night !== autoState) { autoState = night; override = null }   // a boundary passed → back to auto
    }
    function toggle() { override = !active }
    function setAuto() { override = null }

    Timer { interval: 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.evaluate() }
    Connections { target: Weather; function onSunsetChanged() { root.evaluate() } }

    onActiveChanged: apply()
    onAvailableChanged: apply()
    function apply() {
        if (!available) return
        if (active)
            Quickshell.execDetached(["sh", "-c", 'pgrep -x hyprsunset >/dev/null || { hyprsunset >/dev/null 2>&1 & sleep 0.8; }; hyprctl hyprsunset temperature "$1" >/dev/null', "sh", String(temperature)])
        else
            Quickshell.execDetached(["sh", "-c", 'pgrep -x hyprsunset >/dev/null && hyprctl hyprsunset identity >/dev/null; true'])
    }
}
