# SPDX-License-Identifier: GPL-3.0-or-later
# Syntax colours are set as *universal* variables by ~/.config/hypr/scripts/theme.sh
# from the matugen palette (running shells update instantly). These are only
# fallbacks for a machine where theme.sh hasn't run yet.
status is-interactive; or return
set -q fish_color_command; or set -U fish_color_command blue
set -q fish_color_quote; or set -U fish_color_quote yellow
set -q fish_color_error; or set -U fish_color_error brred
set -q fish_color_comment; or set -U fish_color_comment brblack
set -q fish_color_autosuggestion; or set -U fish_color_autosuggestion brblack
