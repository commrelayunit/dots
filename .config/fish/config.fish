# SPDX-License-Identifier: GPL-3.0-or-later
# Fish — default interactive shell (end-4-style experience, written from scratch).
# Bash stays installed as the recovery shell (SUPER+SHIFT+Return → kitty bash --norc).

fish_add_path -g ~/.local/bin

if status is-interactive
    set -g fish_greeting                      # no greeting

    # Starship with a transient prompt (old prompts collapse to the glyph).
    # The plain Linux console can't draw the Nerd Font pills, so skip it there.
    if test "$TERM" != linux; and command -q starship
        starship init fish | source
        enable_transience
    end
end
