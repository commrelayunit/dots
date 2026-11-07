# SPDX-License-Identifier: GPL-3.0-or-later
# Package steps: official repos (pacman) and optional AUR (yay, opt-in only).

# missing_pkgs MANIFEST — packages from MANIFEST not currently installed.
missing_pkgs() {
    local p
    while read -r p; do
        pacman -Qq "$p" >/dev/null 2>&1 || pacman -Qqg "$p" >/dev/null 2>&1 || echo "$p"
    done < <(read_manifest "$1")
}

step_packages() {
    local manifest="$REPO/pkglist.txt"
    step "Official packages ($(read_manifest "$manifest" | wc -l) in pkglist.txt)"
    local missing p
    mapfile -t missing < <(missing_pkgs "$manifest")
    if (( ${#missing[@]} == 0 )); then
        ok "all installed"
        return
    fi
    for p in "${missing[@]}"; do
        pacman -Si "$p" >/dev/null 2>&1 || die "'$p' is not in the configured repositories"
    done
    info "missing: ${missing[*]}"
    run sudo pacman -S --needed "${missing[@]}"
}

step_aur() {
    local manifest="$REPO/pkglist-aur.txt"
    step "Optional AUR packages (--with-aur)"
    local missing
    mapfile -t missing < <(missing_pkgs "$manifest")
    if (( ${#missing[@]} == 0 )); then
        ok "all installed"
        return
    fi
    info "missing: ${missing[*]}"
    if ! command -v yay >/dev/null 2>&1; then
        warn "yay not found — bootstrap it first (see README → AUR helper)"
        return 1
    fi
    run yay -S --needed "${missing[@]}"
}

step_laptop() {
    local manifest="$REPO/pkglist-laptop.txt"
    step "Laptop extras (--with-laptop)"
    local missing
    mapfile -t missing < <(missing_pkgs "$manifest")
    if (( ${#missing[@]} == 0 )); then ok "all installed"; else
        info "missing: ${missing[*]}"
        run sudo pacman -S --needed "${missing[@]}"
    fi
    info "services are NOT enabled by the installer; if wanted:"
    info "  sudo systemctl enable --now bluetooth.service power-profiles-daemon.service"
}
