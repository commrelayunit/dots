#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# ~/Scripts/backup.sh — snapshot of everything the desktop needs to be rebuilt:
#   the dot-files repo (as a git bundle, full history), theme/island state,
#   install backups, notes, ~/.face, ~/Pictures/Wallpapers, and the explicit
#   package lists (official + foreign/AUR).
#
#   backup.sh                 → ~/Backups/kessel/kessel-<timestamp>.tar.zst
#   backup.sh --dest DIR      different destination
#   backup.sh --keep N        keep only the newest N archives (default 10)
#   backup.sh --dry-run       list what would be archived
#
# Deliberately NOT included: ~/.ssh, keyrings, browser profiles, tokens — no secrets.
set -euo pipefail
repo="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
source "$repo/installer/common.sh"

DEST="$HOME/Backups/kessel" KEEP=10
while (( $# )); do
    case $1 in
        --dest) DEST="${2:?}"; shift ;;
        --keep) KEEP="${2:?}"; shift ;;
        --dry-run) DRY_RUN=1 ;;
        -h|--help) sed -n '3,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) die "unknown option: $1" ;;
    esac
    shift
done

ts="$(date +%Y%m%d-%H%M%S)"
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
items=()
add() { [[ -e $1 ]] && items+=("${1#"$HOME"/}") || info "skip (missing): ${1/#$HOME/\~}"; }

step "Collecting"
git -C "$repo" bundle create "$work/dot-files.bundle" --all >/dev/null 2>&1 && ok "dot-files git bundle (all branches)"
git -C "$repo" status --porcelain > "$work/dot-files.uncommitted.txt"
[[ -s $work/dot-files.uncommitted.txt ]] && warn "repo has uncommitted changes — they are listed, not bundled"
pacman -Qqen > "$work/pkglist.native.txt";  ok "official packages: $(wc -l < "$work/pkglist.native.txt")"
pacman -Qqem > "$work/pkglist.foreign.txt"; ok "AUR/foreign packages: $(wc -l < "$work/pkglist.foreign.txt")"
add "$HOME/.local/state/kessel"
add "$HOME/.local/state/dot-files"
add "$HOME/Documents/notes"
add "$HOME/.face"
add "$HOME/Pictures/Wallpapers"
for i in "${items[@]}"; do ok "~/$i"; done

out="$DEST/kessel-$ts.tar.zst"
step "Archive → ${out/#$HOME/\~}"
if (( DRY_RUN )); then
    info "[dry-run] would write the archive above"
    exit 0
fi
mkdir -p "$DEST"
tar --zstd -cf "$out" -C "$work" . -C "$HOME" "${items[@]}"
ok "$(du -h "$out" | cut -f1)  $(tar --zstd -tf "$out" | wc -l) entries"

step "Rotation (keep $KEEP)"
mapfile -t old < <(ls -1t "$DEST"/kessel-*.tar.zst 2>/dev/null | tail -n +$((KEEP + 1)))
for f in "${old[@]}"; do rm -f "$f"; info "removed $(basename "$f")"; done
info "restore: tar --zstd -xf <archive> -C ~   ·   git clone dot-files.bundle ~/dot-files"
