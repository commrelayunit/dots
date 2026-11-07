#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# ~/Scripts/install.sh — fresh install / re-apply. Thin wrapper around the repo's
# install.sh; all its flags work here (see ./install.sh --help).
#   ~/Scripts/install.sh --dry-run          preview
#   ~/Scripts/install.sh                    packages + config links (the usual)
set -euo pipefail
repo="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
if (( $# == 0 )); then set -- --profile minimal --apply-config; fi
exec "$repo/install.sh" "$@"
