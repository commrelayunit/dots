# SPDX-License-Identifier: GPL-3.0-or-later
# Familiar shortcuts. Optional tools are only aliased when installed.
status is-interactive; or return

alias pamcan pacman
alias clear "printf '\033[2J\033[3J\033[1;1H'"
abbr -a -g g git
abbr -a -g gs 'git status -sb'
abbr -a -g gl 'git log --oneline --graph -20'
abbr -a -g hc hyprctl
abbr -a -g up 'sudo pacman -Syu'

if command -q eza
    alias ls 'eza --icons --group-directories-first'
    alias ll 'eza -l --icons --git --group-directories-first'
    alias la 'eza -la --icons --git --group-directories-first'
else
    alias ll 'ls -lh --color=auto'
    alias la 'ls -lAh --color=auto'
end
