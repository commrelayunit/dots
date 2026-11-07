// SPDX-License-Identifier: GPL-3.0-or-later
// Weather from wttr.in (JSON). One request per Config.weatherIntervalMin.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Singleton {
    id: root

    property bool ok: false
    property string temp: ""
    property string feels: ""
    property string desc: ""
    property string area: ""
    property string humidity: ""
    property string wind: ""
    property int code: 0
    property var forecast: []      // [{ day, max, min, code }]

    readonly property string icon: iconFor(code, Time.now.getHours())

    function iconFor(c, hour) {
        const night = hour < 6 || hour >= 20
        if (c === 113) return night ? Icons.night : Icons.sunny
        if (c === 116) return Icons.partly
        if (c === 119 || c === 122) return Icons.cloudy
        if ([143, 248, 260].indexOf(c) >= 0) return Icons.fog
        if ([200, 386, 389, 392, 395].indexOf(c) >= 0) return Icons.storm
        if ([179, 182, 185, 227, 230, 281, 284, 311, 314, 317, 320, 323, 326, 329, 332, 335, 338, 350, 362, 365, 368, 371, 374, 377].indexOf(c) >= 0) return Icons.snow
        if (c >= 176) return Icons.rain
        return Icons.cloudy
    }

    function refresh() { if (Config.weatherEnabled && !proc.running) proc.running = true }

    Process {
        id: proc
        command: ["curl", "-fsS", "--max-time", "15",
                  "https://wttr.in/" + encodeURIComponent(Config.weatherLocation) + "?format=j1&" + Config.weatherUnits]
        stdout: StdioCollector { onStreamFinished: root.parse(text) }
    }

    function parse(text) {
        try {
            const j = JSON.parse(text)
            const c = j.current_condition[0]
            const metric = Config.weatherUnits !== "u"
            const t = v => String(parseInt(v) || 0) + "°"   // wttr can send "-0"
            temp = t(metric ? c.temp_C : c.temp_F)
            feels = t(metric ? c.FeelsLikeC : c.FeelsLikeF)
            desc = c.weatherDesc[0].value
            humidity = c.humidity + "%"
            wind = (metric ? c.windspeedKmph + " km/h" : c.windspeedMiles + " mph")
            code = parseInt(c.weatherCode)
            area = j.nearest_area?.[0]?.areaName?.[0]?.value ?? ""
            forecast = (j.weather || []).map(d => ({
                day: Qt.formatDate(new Date(d.date), "ddd"),
                max: t(metric ? d.maxtempC : d.maxtempF),
                min: t(metric ? d.mintempC : d.mintempF),
                code: parseInt(d.hourly?.[4]?.weatherCode ?? 116)
            }))
            ok = true
        } catch (e) {
            console.warn("weather: could not parse wttr.in response")
        }
    }

    Timer {
        running: Config.weatherEnabled
        interval: Config.weatherIntervalMin * 60000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
