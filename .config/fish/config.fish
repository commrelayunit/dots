# SPDX-License-Identifier: GPL-3.0-or-later
# Fish — default interactive shell. Bash stays installed as the recovery shell
# (SUPER+SHIFT+Return opens `kitty bash --norc`).

fish_add_path -g ~/.local/bin

if status is-interactive
    set -g fish_greeting                     # quiet start, end-4 style

    if command -q starship
        starship init fish | source
        enable_transience                    # collapse old prompts to ❯
    end
end
