#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# lock.sh — lock the session with the Kessel lock screen (Quickshell).
# Safety: if Quickshell is missing or the compositor does not confirm a secure
# lock within 3 s, hyprlock is used instead. Never leaves the session unlocked
# by accident, never stacks two lockers.
#
# Recovery from SSH if a locker ever wedges (session stays locked, red screen):
#   qs kill -c kessel-lock
#   hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'          # (tested) — or start hyprlock:
#   hyprctl dispatch 'hl.dsp.exec_cmd("hyprlock")'
set -u
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [[ -z ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
    HYPRLAND_INSTANCE_SIGNATURE="$(ls -t "$XDG_RUNTIME_DIR/hypr" 2>/dev/null | head -1)"; export HYPRLAND_INSTANCE_SIGNATURE
fi
if [[ -z ${WAYLAND_DISPLAY:-} ]]; then
    WAYLAND_DISPLAY="$(cd "$XDG_RUNTIME_DIR" && ls wayland-[0-9] 2>/dev/null | head -1)"; export WAYLAND_DISPLAY
fi

cfg="$HOME/.config/quickshell/kessel-lock/shell.qml"
qs_lock_running() { qs list --all 2>/dev/null | grep -q "/quickshell/kessel-lock/shell.qml"; }

# Already locked (by us or hyprlock)? Nothing to do.
qs_lock_running && exit 0
pidof hyprlock >/dev/null && exit 0

fallback() { exec hyprlock; }

command -v qs >/dev/null 2>&1 && [[ -f $cfg ]] || fallback

# The island must not hold a keyboard grab / open panel under the lock.
qs -c kessel ipc call island close >/dev/null 2>&1 || true

qs -n -c kessel-lock -d >/dev/null 2>&1 || fallback
for _ in $(seq 1 30); do
    [[ "$(qs -c kessel-lock ipc call lockstate secure 2>/dev/null)" == yes ]] && exit 0
    sleep 0.1
done
# Not confirmed: get rid of the half-started locker and use hyprlock.
qs kill -c kessel-lock >/dev/null 2>&1 || true
fallback
