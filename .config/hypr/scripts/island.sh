#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# island.sh start|stop|restart|status — manage the Quickshell island.
# Purely optional: the desktop works without it.
#
# Notifications: the island owns org.freedesktop.Notifications while it runs.
# dunst stays installed and D-Bus activatable, so if the island is stopped or
# crashes, the next notification starts dunst automatically. We only *stop*
# dunst here (never disable it) so the island can claim the name.
set -u
cfg=kessel
# Allow starting from SSH / a TTY: find the session the island belongs to.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [[ -z ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
    HYPRLAND_INSTANCE_SIGNATURE="$(ls -t "$XDG_RUNTIME_DIR/hypr" 2>/dev/null | head -1)"; export HYPRLAND_INSTANCE_SIGNATURE
fi
if [[ -z ${WAYLAND_DISPLAY:-} ]]; then
    WAYLAND_DISPLAY="$(cd "$XDG_RUNTIME_DIR" && ls wayland-[0-9] 2>/dev/null | head -1)"; export WAYLAND_DISPLAY
fi
have() { command -v qs >/dev/null 2>&1 && [[ -f "$HOME/.config/quickshell/$cfg/shell.qml" ]]; }
running() { qs list --all 2>/dev/null | grep -q "/quickshell/$cfg/shell.qml"; }
case "${1:-start}" in
    start)
        have || exit 0
        running && exit 0
        systemctl --user stop dunst.service 2>/dev/null || true
        export QS_ICON_THEME="${QS_ICON_THEME:-Papirus-Dark}"
        qs -n -c "$cfg" -d >/dev/null 2>&1 ;;
    stop)
        # Close any open panel first: tearing down a focused text field crashes
        # Qt 6.12 at shutdown (QInputMethod::commit in ~QQuickItem).
        qs -c "$cfg" ipc call island close >/dev/null 2>&1 && sleep 0.3
        qs kill -c "$cfg" >/dev/null 2>&1 || true ;;   # never pkill -f: too broad
    restart) "$0" stop; sleep 0.4; "$0" start ;;
    status)  qs list --all 2>/dev/null ;;
    *)       echo "usage: $0 start|stop|restart|status" >&2; exit 2 ;;
esac
