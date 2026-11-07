#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# island.sh start|stop|restart|status — manage the Quickshell island.
# Purely optional: the desktop works without it.
set -u
cfg=kessel
have() { command -v qs >/dev/null 2>&1 && [[ -f "$HOME/.config/quickshell/$cfg/shell.qml" ]]; }
case "${1:-start}" in
    start)   have || exit 0; qs -n -c "$cfg" -d >/dev/null 2>&1 ;;
    stop)    qs kill -c "$cfg" >/dev/null 2>&1 || pkill -f "qs -c $cfg" ;;
    restart) "$0" stop; sleep 0.3; "$0" start ;;
    status)  qs list --all 2>/dev/null ;;
    *)       echo "usage: $0 start|stop|restart|status" >&2; exit 2 ;;
esac
