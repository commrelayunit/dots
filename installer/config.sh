# SPDX-License-Identifier: GPL-3.0-or-later
# Config deployment: symlinks into the repo, with timestamped, reversible backups.
#
# Every run that changes something writes $BACKUP_ROOT/<ts>/MANIFEST with one line
# per action:   LINK <dest>          (dest did not exist; rollback removes the link)
#               REPLACE <dest>       (old dest moved to <ts>/<dest-rel>; rollback restores)
#               GSETTINGS <schema> <key> <old-value>
# `install.sh --rollback [ts]` replays it in reverse.

link_status() { # link_status SRC DEST → ok|missing|other
    local src=$1 dest=$2
    if [[ -L $dest && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
        echo ok
    elif [[ ! -e $dest && ! -L $dest ]]; then
        echo missing
    else
        echo other
    fi
}

step_config() {
    local links="$REPO/profiles/$PROFILE.links"
    [[ -f $links ]] || die "no link manifest for profile '$PROFILE'"
    step "Config links ($PROFILE profile)"

    local ts; ts="$(date +%Y%m%d-%H%M%S)"
    local bdir="$BACKUP_ROOT/$ts" changed=0
    local src_rel dest_rel src dest status

    while IFS=$'\t' read -r src_rel dest_rel; do
        src="$REPO/$src_rel"
        dest="$HOME/$dest_rel"
        if [[ ! -e $src ]]; then
            warn "skip $src_rel (not in repo yet)"
            continue
        fi
        status="$(link_status "$src" "$dest")"
        case $status in
            ok)
                ok "~/$dest_rel" ;;
            missing)
                info "link ~/$dest_rel → $src_rel"
                run mkdir -p "$(dirname "$dest")"
                run ln -s "$src" "$dest"
                record "$bdir" "LINK $dest_rel"
                changed=1 ;;
            other)
                warn "~/$dest_rel exists and is not our link → backing up to $bdir/$dest_rel"
                if [[ -d $dest && ! -L $dest ]] && command -v diff >/dev/null; then
                    diff -rq "$dest" "$src" 2>/dev/null | sed 's/^/      /' | head -10 || true
                elif [[ -f $dest ]]; then
                    diff -u "$dest" "$src" 2>/dev/null | head -15 | sed 's/^/      /' || true
                fi
                run mkdir -p "$(dirname "$bdir/$dest_rel")"
                run mv "$dest" "$bdir/$dest_rel"
                run mkdir -p "$(dirname "$dest")"
                run ln -s "$src" "$dest"
                record "$bdir" "REPLACE $dest_rel"
                changed=1 ;;
        esac
    done < <(read_links "$links")

    step_gsettings "$bdir" && changed=1 || true

    if (( changed )) && (( ! DRY_RUN )); then
        ok "backup + rollback manifest: $bdir/MANIFEST"
        info "rollback: ./install.sh --rollback $ts"
    fi
}

record() { # record BDIR LINE
    (( DRY_RUN )) && return 0
    mkdir -p "$1"
    printf '%s\n' "$2" >> "$1/MANIFEST"
}

# Font/colour defaults for GTK4/libadwaita apps (they read gsettings, not settings.ini).
GSETTINGS_WANT=(
    "org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 11'"
    "org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 12'"
    "org.gnome.desktop.interface color-scheme 'prefer-dark'"
    "org.gnome.desktop.interface icon-theme 'Papirus-Dark'"
)

step_gsettings() { # returns 0 if something changed
    command -v gsettings >/dev/null 2>&1 || return 1
    local bdir=$1 line schema key want cur changed=1
    for line in "${GSETTINGS_WANT[@]}"; do
        read -r schema key want <<<"$line"
        cur="$(gsettings get "$schema" "$key" 2>/dev/null)" || continue
        if [[ $cur == "$want" ]]; then
            ok "gsettings $key = $want"
        else
            info "gsettings $key: $cur → $want"
            run gsettings set "$schema" "$key" "${want//\'/}"
            record "$bdir" "GSETTINGS $schema $key $cur"
            changed=0
        fi
    done
    return $changed
}

step_rollback() {
    local ts=${1:-}
    if [[ -z $ts ]]; then
        ts="$(ls -1 "$BACKUP_ROOT" 2>/dev/null | while read -r d; do [[ -f $BACKUP_ROOT/$d/MANIFEST ]] && echo "$d"; done | tail -1)"
    fi
    local bdir="$BACKUP_ROOT/$ts"
    [[ -n $ts && -f $bdir/MANIFEST ]] || die "no rollback manifest found (${bdir:-none})"
    step "Rollback $ts"
    local action a b c dest
    while read -r action a b c; do
        case $action in
            LINK|REPLACE)
                dest="$HOME/$a"
                if [[ -L $dest && "$(readlink -f "$dest")" == "$REPO"/* ]]; then
                    run rm "$dest"
                else
                    warn "~/$a is no longer our link — leaving it alone"
                    continue
                fi
                if [[ $action == REPLACE ]]; then
                    run mv "$bdir/$a" "$dest"
                    ok "restored ~/$a"
                else
                    ok "removed link ~/$a"
                fi ;;
            GSETTINGS)
                run gsettings set "$a" "$b" "$(sed "s/^'//; s/'$//" <<<"$c")"
                ok "gsettings $b ← $c" ;;
        esac
    done < <(tac "$bdir/MANIFEST")
    (( DRY_RUN )) || mv "$bdir/MANIFEST" "$bdir/MANIFEST.rolled-back"
}
