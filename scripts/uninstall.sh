#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# ~/Scripts/uninstall.sh — undo every config deployment, newest first, which
# restores the files that existed before (including the original hyprland.lua).
#
#   uninstall.sh --dry-run   show exactly what would be removed/restored (do this first!)
#   uninstall.sh             do it (asks for confirmation)
#   uninstall.sh --purge     also delete generated state (~/.local/state/kessel)
#
# Never removes packages, never touches the repo itself, and keeps all backups.
# Packages installed by the profile are listed at the end for manual removal.
set -euo pipefail
repo="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
source "$repo/installer/common.sh"
source "$repo/installer/config.sh"

PURGE=0
for a in "$@"; do
    case $a in
        --dry-run) DRY_RUN=1 ;;
        --purge) PURGE=1 ;;
        -h|--help) sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) die "unknown option: $a" ;;
    esac
done
(( DRY_RUN )) && printf '%sDRY RUN — nothing will be changed.%s\n' "$C_B$C_Y" "$C_0"

mapfile -t deployments < <(ls -1 "$BACKUP_ROOT" 2>/dev/null | while read -r d; do [[ -f $BACKUP_ROOT/$d/MANIFEST ]] && echo "$d"; done | sort -r)
step "Deployments to undo (newest first): ${#deployments[@]}"
for d in "${deployments[@]}"; do info "$d"; done

if (( ! DRY_RUN )); then
    read -r -p "  Undo all of them? Hyprland will reload its previous config. [y/N] " yn
    [[ $yn == [yY]* ]] || die "aborted"
fi
for d in "${deployments[@]}"; do step_rollback "$d"; done

# Any of our links left over (e.g. created outside a recorded deployment)
step "Leftover links into the repo"
while IFS=$'\t' read -r s dst; do
    t="$HOME/$dst"
    if [[ -L $t && "$(readlink -f "$t")" == "$repo"/* ]]; then run rm "$t"; ok "$( (( DRY_RUN )) && echo "would ")remove ~/$dst"; fi
done < <(read_links "$repo/profiles/minimal.links")

if (( PURGE )); then
    step "Generated state"
    run rm -rf "${XDG_STATE_HOME:-$HOME/.local/state}/kessel"
fi

step "Not touched"
info "repo: $repo   backups: $BACKUP_ROOT"
info "login shell: $(getent passwd "$USER" | cut -d: -f7)  (restore bash with: chsh -s /usr/bin/bash)"
info "packages from pkglist.txt stay installed; remove manually if wanted:"
info "  sudo pacman -Rns <pkg>…   (see $repo/pkglist.txt)"
