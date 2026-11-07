// SPDX-License-Identifier: GPL-3.0-or-later
// Session actions + idle inhibit. The session is started by uwsm.
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property bool inhibitIdle: false
    // Global tiling/floating layout mode (owned by Hyprland: lib/floatmode.lua)
    property bool floatMode: false
    function toggleFloatMode() { Quickshell.execDetached(["hyprctl", "dispatch", "KesselToggleFloat"]) }

    function lock()     { Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/lock.sh"]) }
    function suspend()  { Quickshell.execDetached(["sh", "-c", "\"$HOME/.config/hypr/scripts/lock.sh\"; sleep 1; systemctl suspend"]) }
    function logout()   { Quickshell.execDetached(["uwsm", "stop"]) }
    function reboot()   { Quickshell.execDetached(["systemctl", "reboot"]) }
    function poweroff() { Quickshell.execDetached(["systemctl", "poweroff"]) }
}
