#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Show the shortcuts generated from keybinds.lua (written on every config load).
set -euo pipefail
pkill -x fuzzel 2>/dev/null && exit 0
f="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/kessel-shortcuts.txt"
[[ -r $f ]] || { notify-send "Shortcuts" "No shortcuts file yet — reload Hyprland (SUPER+CTRL+R)"; exit 0; }
fuzzel --dmenu --prompt '  ' --placeholder 'Search shortcuts' --width 90 --lines 20 < "$f" >/dev/null || true
