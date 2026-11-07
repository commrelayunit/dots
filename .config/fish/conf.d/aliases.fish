# SPDX-License-Identifier: GPL-3.0-or-later
# Familiar shortcuts. Optional tools are only aliased when installed.
status is-interactive; or return

# kitty needs the full escape sequence to really clear scrollback
alias clear "printf '\033[2J\033[3J\033[1;1H'"
alias celar clear
alias claer clear
alias pamcan pacman
alias q 'qs -c kessel'

if test "$TERM" != linux; and command -q eza
    alias ls 'eza --icons=auto --group-directories-first'
    alias ll 'eza -l --icons=auto --git --group-directories-first'
    alias la 'eza -la --icons=auto --git --group-directories-first'
    alias lt 'eza --tree --level=2 --icons=auto'
else
    alias ll 'ls -lh --color=auto'
    alias la 'ls -lAh --color=auto'
end

# kitty's ssh kitten copies terminfo to the remote host
if test "$TERM" = xterm-kitty
    alias ssh 'kitten ssh'
end

abbr -a -g g git
abbr -a -g gs 'git status -sb'
abbr -a -g gl 'git log --oneline --graph -20'
abbr -a -g hc hyprctl
abbr -a -g up 'sudo pacman -Syu'
abbr -a -g yup 'yay -Syu'
