-- SPDX-License-Identifier: GPL-3.0-or-later
-- Autostart / session processes. Run once per Hyprland start (not on reload).
-- Nothing here enables systemd services.

local HOME = os.getenv("HOME")

-- Feature toggles ----------------------------------------------------------------
-- Automatic idle locking stays OFF until manual lock/unlock with hyprlock
-- has been verified in the VM session (SUPER+L).
local ENABLE_IDLE   = false
local ENABLE_ISLAND = true

hl.on("hyprland.start", function()
    -- Remote access: WayVNC strictly on loopback (use an SSH tunnel). Never change the address.
    hl.exec_cmd("wayvnc 127.0.0.1 5900")

    -- Desktop plumbing
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- Notifications: dunst is D-Bus activated on first notification; nothing to start.

    if ENABLE_IDLE then hl.exec_cmd("hypridle") end
    if ENABLE_ISLAND then hl.exec_cmd(HOME .. "/.config/hypr/scripts/island.sh start") end
end)
