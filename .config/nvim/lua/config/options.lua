-- SPDX-License-Identifier: GPL-3.0-or-later
-- On top of LazyVim's defaults (https://lazyvim.org/configuration/general).
local o = vim.opt
o.relativenumber = false     -- plain line numbers, like VS Code
o.scrolloff = 6
o.wrap = false
o.spelllang = { "en" }       -- :set spell (on by default for markdown / tex / git commits)
o.mousemoveevent = true      -- hover effects in the tab bar / tree
vim.g.autoformat = true      -- format on save (toggle: <leader>uf)
vim.g.vimtex_view_method = "zathura"
