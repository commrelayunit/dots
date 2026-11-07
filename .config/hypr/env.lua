-- SPDX-License-Identifier: GPL-3.0-or-later
-- Environment / desktop integration.
-- Note: the session is started by uwsm, which already exports the XDG_* session
-- variables to systemd; these are for processes Hyprland spawns.

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Toolkits: prefer native Wayland, fall back to X11.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland,x11")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.env("TERMINAL", "kitty")

-- Icon theme for Quickshell (island app icons) and Qt apps.
hl.env("QS_ICON_THEME", "Papirus-Dark")
