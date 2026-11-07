# SPDX-License-Identifier: GPL-3.0-or-later
# Syntax colours use terminal palette names, so they follow the wallpaper theme.
status is-interactive; or return
set -g fish_color_command blue
set -g fish_color_param cyan
set -g fish_color_quote yellow
set -g fish_color_error brred
set -g fish_color_comment brblack
set -g fish_color_autosuggestion brblack
set -g fish_color_operator brcyan
set -g fish_color_escape brcyan
set -g fish_color_redirection cyan --bold
set -g fish_color_end green
set -g fish_color_valid_path --underline
set -g fish_pager_color_prefix cyan --bold --underline
set -g fish_pager_color_description yellow -i
set -g fish_pager_color_progress brwhite --background=cyan
