#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Kessel dots installer — idempotent, explicit, reversible.
#
#   ./install.sh --dry-run --profile minimal --with-aur --apply-config   # preview everything
#   ./install.sh --profile minimal                                       # official packages only
#   ./install.sh --profile minimal --apply-config                        # + deploy config links
#   ./install.sh --with-aur                                              # + optional AUR (yay)
#   ./install.sh --with-laptop                                           # + bluez, power-profiles-daemon
#   ./install.sh --with-translate                                        # + offline translation (downloads models)
#   ./install.sh --check                                                 # read-only verification
#   ./install.sh --rollback [timestamp]                                  # undo a config deployment
#
# Never: enables services, touches SSH/network/firewall, changes the login
# shell (use --set-shell explicitly), reads or writes secrets.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=installer/common.sh
source "$REPO/installer/common.sh"
source "$REPO/installer/packages.sh"
source "$REPO/installer/config.sh"
source "$REPO/installer/checks.sh"

PROFILE=minimal
WITH_AUR=0 WITH_LAPTOP=0 WITH_TRANSLATE=0 APPLY_CONFIG=0 SET_SHELL=0 CHECK_ONLY=0 ROLLBACK=0 ROLLBACK_TS="" SKIP_PACKAGES=0

usage() { sed -n '3,16p' "$0" | sed 's/^# \{0,1\}//'; }

while (( $# )); do
    case $1 in
        --dry-run)       DRY_RUN=1 ;;
        --profile)       PROFILE="${2:?--profile needs a value}"; shift ;;
        --profile=*)     PROFILE="${1#*=}" ;;
        --with-aur)      WITH_AUR=1 ;;
        --with-laptop)   WITH_LAPTOP=1 ;;
        --with-translate) WITH_TRANSLATE=1 ;;
        --apply-config)  APPLY_CONFIG=1 ;;
        --skip-packages) SKIP_PACKAGES=1 ;;
        --set-shell)     SET_SHELL=1 ;;
        --check)         CHECK_ONLY=1 ;;
        --rollback)      ROLLBACK=1; if [[ ${2:-} =~ ^[0-9]{8}-[0-9]{6}$ ]]; then ROLLBACK_TS=$2; shift; fi ;;
        -h|--help)       usage; exit 0 ;;
        *)               usage; die "unknown option: $1" ;;
    esac
    shift
done

[[ $PROFILE == minimal ]] || die "unknown profile '$PROFILE' (available: minimal)"
(( EUID != 0 )) || die "run as your normal user, not root (sudo is used only for pacman)"
[[ -f /etc/arch-release ]] || die "this installer targets Arch Linux"

(( DRY_RUN )) && printf '%sDRY RUN — nothing will be changed.%s\n' "$C_B$C_Y" "$C_0"

if (( ROLLBACK )); then step_rollback "$ROLLBACK_TS"; exit 0; fi
if (( CHECK_ONLY )); then step_check; exit $?; fi

(( SKIP_PACKAGES )) || step_packages
(( WITH_AUR )) && { step_aur || warn "AUR step incomplete"; }
(( WITH_LAPTOP )) && step_laptop
if (( APPLY_CONFIG )); then
    step_config
else
    step "Config links"; info "skipped (pass --apply-config to deploy)"
fi
(( WITH_TRANSLATE )) && { step_translate || warn "translation setup incomplete"; }

if (( SET_SHELL )); then
    step "Login shell"
    if [[ "$(getent passwd "$USER" | cut -d: -f7)" == /usr/bin/fish ]]; then
        ok "already fish"
    else
        # Not in dry-run: fish creates ~/.config/fish on its first start.
        if (( ! DRY_RUN )); then
            fish -c 'exit 0' || die "fish does not start — not changing the login shell"
        fi
        info "rollback: chsh -s /usr/bin/bash"
        run chsh -s /usr/bin/fish
    fi
fi

(( DRY_RUN )) && { step "Dry run complete"; info "no changes were made"; exit 0; }
step_check || warn "some checks failed — see above"
