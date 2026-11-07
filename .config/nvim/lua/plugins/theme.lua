-- SPDX-License-Identifier: GPL-3.0-or-later
-- Colours follow the desktop (see lua/kessel/theme.lua and docs/THEME.md).
return {
  { "nvim-mini/mini.base16", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        local theme = require("kessel.theme")
        theme.apply()
        theme.watch()
      end,
    },
  },
  -- tab bar and status line pick up the same colours
  { "akinsho/bufferline.nvim", opts = { options = { separator_style = "thin", always_show_bufferline = true } } },
  { "nvim-lualine/lualine.nvim", opts = { options = { theme = "auto" } } },
}
