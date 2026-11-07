#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Regenerate docs/SHORTCUTS.md from .config/hypr/keybinds.lua (the single registry).
# Uses Hyprland's offline --verify-config, so it never touches the running session.
set -euo pipefail
repo="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"   # works via ~/Scripts too
out="$repo/docs/SHORTCUTS.md"
res="$(KESSEL_STRICT=1 KESSEL_SHORTCUTS_MD="$out" XDG_RUNTIME_DIR="$(mktemp -d)" \
       Hyprland --verify-config -c "$repo/.config/hypr/hyprland.lua" 2>&1 | tail -1)"
[[ $res == "config ok" ]] || { echo "config invalid: $res" >&2; exit 1; }
echo "wrote $out"
