// SPDX-License-Identifier: GPL-3.0-or-later
// Island behaviour knobs. Edit and save: Quickshell hot-reloads.
pragma Singleton
import Quickshell

Singleton {
    // Weather via wttr.in (one HTTPS request every `weatherIntervalMin`).
    // Empty location = wttr.in guesses from your public IP. Example: "Vienna".
    readonly property bool   weatherEnabled: true
    readonly property string weatherLocation: ""
    readonly property string weatherUnits: "m"        // "m" metric, "u" imperial
    readonly property int    weatherIntervalMin: 30

    // Launcher translation: source language for ">en …" when the text isn't Cyrillic
    readonly property string translateFrom: "de"
    readonly property int nightTemperature: 4000       // night light colour temperature (K)

    readonly property int notifTimeoutMs: 5000        // when the app does not set one
    readonly property int osdMs: 1400
    readonly property int hoverDelayMs: 300           // pointer rest before the summary opens

    readonly property string recordDir: Quickshell.env("HOME") + "/Videos/Recordings"
    readonly property list<int> timerPresets: [1, 5, 10, 25, 45]
}
